//
//  CalendarViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import JTAppleCalendar
import CoreData

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var sun: UILabel!
    @IBOutlet weak var mon: UILabel!
    @IBOutlet weak var tues: UILabel!
    @IBOutlet weak var wed: UILabel!
    @IBOutlet weak var thurs: UILabel!
    @IBOutlet weak var fri: UILabel!
    @IBOutlet weak var sat: UILabel!
    
    var presentedMonth: Int = NSCalendar.current.component(.month, from: Date())
    var presentedYear: Int = NSCalendar.current.component(.year, from: Date())
    var presentedDate: Date = Date()
    let formatter = DateFormatter()

    var selectedEvents: [NSManagedObject] = []
    let loggedSymptoms = [NSManagedObject]()

    var selectedDate: Date?
    
    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.f.string(from: Date())
        return aString
        }()
    lazy var f : DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy MM dd"
        
        return f
    }()

    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    let symptomFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Symptom")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy MM dd"
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        self.calendarView.scrollEnabled = false
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false) {
            self.presentedDate = Date()
            self.setupViewsOfCalendar(startDate: self.presentedDate)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.calendarView.scrollToNextSegment(){
            if self.presentedMonth < 12{
                self.presentedDate = self.formatter.date(from: "\(self.presentedYear) \(self.presentedMonth + 1) 01")!}
            else {
                self.presentedDate = self.formatter.date(from: "\(self.presentedYear + 1) 01 01")!
            }
            self.setupViewsOfCalendar(startDate: self.presentedDate)
        }
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        self.calendarView.scrollToPreviousSegment(){
            if self.presentedMonth > 1{
                self.presentedDate = self.formatter.date(from: "\(self.presentedYear) \(self.presentedMonth - 1) 01")!}
            else {
                self.presentedDate = self.formatter.date(from: "\(self.presentedYear - 1) 12 01")!
            }
            self.setupViewsOfCalendar(startDate: self.presentedDate)
        }
        
    }
    func setupViewsOfCalendar(startDate: Date) {
        presentedMonth = NSCalendar.current.component(.month, from: startDate)
        let monthName = formatter.monthSymbols[(presentedMonth-1)] // 0 indexed array
        presentedYear = NSCalendar.current.component(.year, from: startDate)
        monthLabel.text = monthName.uppercased()
        yearLabel.text = String(presentedYear)
    }
    
}



extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = formatter.date(from: "2016 01 01")!
        let limitYear = NSCalendar.current.component(.year, from: Date()) + 2
        let endDate = formatter.date(from: "\(limitYear) 01 01")!
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: Calendar.current,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let cell = cell as! CellView
        
        cell.setupCellBeforeDisplay(cellState: cellState, date: date)
   
        //Here is where to right code to add events to event on this day of cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.reloadData()

    }
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            cell.dayLabel.textColor = UIColor(hexString: "85CEC4")
        } else {
            if cellState.dateBelongsTo == .thisMonth{
                cell.dayLabel.textColor = UIColor.white
            } else {
                cell.dayLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        print("Cell selected at \(date)")
        if !formatter.string(from: date).isEqual(todayDate) {

            handleCellSelection(view: cell, cellState: cellState)
        }
        //let cell = cell as! CellView
        //selectedEvents = cell.eventsOnThisDay
        //tableView.reloadData()

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
    }
  
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell") as! CalendarTableViewCell
        
        if loggedSymptoms.count > 0 {
            let symptom = loggedSymptoms[indexPath.row]
            cell.titleLabel.isHidden = false
            cell.titleLabel.text = symptom.value(forKey: "symptom") as? String
            
            return cell
        }
//        if selectedEvents.count > 0 {
//            if let appointment = selectedEvents[indexPath.item].appointment {
//                cell.titleLabel.isHidden = false
//                cell.titleLabel.text = "Doctor Appointment"
//                
//                cell.descriptionLabel.isHidden = false
//                cell.descriptionLabel.text = "Memorial Health"
//                
//                cell.timeLabel.isHidden = false
//                cell.timeLabel.text = appointment.scheduledTime.description
//                
//                cell.typeIndicator.isHidden = false
//                cell.typeIndicator.image = UIImage(named: "appointment circle")
//                
//                cell.symptomIcon.isHidden = true
//            }
//            if let symptom = selectedEvents[indexPath.item].symptom{
//                cell.titleLabel.isHidden = false
//                cell.titleLabel.text = symptom.symptomName
//                
//                if let description = selectedEvents[indexPath.item].description{
//                    cell.descriptionLabel.text = description
//                    cell.descriptionLabel.isHidden = false
//                }
//                
//                cell.typeIndicator.isHidden = false
//                cell.typeIndicator.image = UIImage(named: "symptom circle")
//                
//                cell.timeLabel.isHidden = true
//            }
//            
//            return cell
//        }
        else {
            cell.titleLabel.isHidden = true
            cell.descriptionLabel.text = "No Events To Show"
            cell.timeLabel.isHidden = true
            cell.symptomIcon.isHidden = true
            cell.typeIndicator.isHidden = true
            return cell
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedEvents.count  > 0 {
            //later will be selectedEvents.count
            return loggedSymptoms.count
        }
        return 1
        
    }
}
