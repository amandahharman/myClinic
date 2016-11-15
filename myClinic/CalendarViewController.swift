//
//  CalendarViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import JTAppleCalendar

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
    
    var eventArray: [CalendarEvent] = []
    var selectedEvents: [CalendarEvent] = []
    var selectedDate: Date?
    
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
        
        eventArray.append(CalendarEvent(symptom: Symptom(symptomID: 1, symptomName: "Headache"), description: "Periodically throughout the day", date: "2016 11 13"))
        
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
        if self.eventArray.count > 0 {
            for event in eventArray {
                let eventDate = formatter.date(from: event.startDate)
                if date == eventDate{
                    cell.eventLine.isHidden = false
                    cell.eventsOnThisDay.append(event)
                    
                }
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.reloadData()

    }
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let cell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        print("Cell selected at \(date)")
        handleCellSelection(view: cell, cellState: cellState)
        let cell = cell as! CellView
        selectedEvents = cell.eventsOnThisDay
        tableView.reloadData()

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell") as! CalendarTableViewCell
        if selectedEvents.count > 0 {
            if let appointment = selectedEvents[indexPath.item].appointment {
                cell.titleLabel.text = "Doctor Appointment"
                
                cell.descriptionLabel.isHidden = false
                cell.descriptionLabel.text = "Memorial Health"
                
                cell.timeLabel.isHidden = false
                cell.timeLabel.text = appointment.scheduledTime.description
                
                cell.typeIndicator.isHidden = false
                cell.typeIndicator.image = UIImage(named: "appointment circle")
                
                cell.symptomIcon.isHidden = true
            }
            if let symptom = selectedEvents[indexPath.item].symptom{
                cell.titleLabel.text = symptom.symptomName
                
                if let description = selectedEvents[indexPath.item].description{
                    cell.descriptionLabel.text = description
                    cell.descriptionLabel.isHidden = false
                }
                
                cell.typeIndicator.isHidden = false
                cell.typeIndicator.image = UIImage(named: "symptom circle")
                
                cell.timeLabel.isHidden = true
            }
            
            return cell
        }
        else {
            cell.titleLabel.text = "No Events To Show"
            cell.descriptionLabel.isHidden = true
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
            return selectedEvents.count
        }
        return 1
        
    }
}
