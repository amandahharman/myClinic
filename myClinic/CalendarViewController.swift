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

class CalendarViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
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
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    let symptomFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Symptom")
    let appointmentsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Appointment")

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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.reloadData()
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
    
    func fetchRequest(request: NSFetchRequest<NSFetchRequestResult>, date: String){
        let  fetchRequest = request
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "date== %@", date)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do{
            try
                fetchedResultsController?.performFetch()
            print("Fetch succeeded")
        }
        catch{
            print("Fetch failed")
        }
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
        fetchRequest(request: symptomFetchRequest, date: f.string(from: date))
        showEventIndicator(view: cell)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.reloadData()
        
    }
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState, date: Date) {
        guard let cell = view as? CellView  else {
            return
        }
        if !formatter.string(from: date).isEqual(todayDate) {
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

    }
    func showEventIndicator(view:JTAppleDayCellView?){
        guard let cell = view as? CellView  else {
            return
        }
        if let numObject = fetchedResultsController?.fetchedObjects {
            if numObject.count > 0{
                cell.eventIndicator.isHidden = false
            }
            else {
                cell.eventIndicator.isHidden = true
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        print("Cell selected at \(date)")
        fetchRequest(request: symptomFetchRequest, date: f.string(from: date))
        handleCellSelection(view: cell, cellState: cellState, date: date)
        tableView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    
    func configureCell(cell: CalendarTableViewCell, object: NSManagedObject){
        if let symptom = object as? Symptom{
            cell.titleLabel.isHidden = false
            cell.titleLabel.text = symptom.name
            if let desc = symptom.desc{
            cell.descriptionLabel.isHidden = false
            cell.descriptionLabel.text = desc
            }
            cell.typeIndicator.isHidden = false
            cell.typeIndicator.image = UIImage(named: "symptom circle")
            if let time = symptom.time{
            cell.timeLabel.isHidden = false
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            cell.timeLabel.text = timeFormatter.string(from:time as Date)
            }
            print(symptom.time)
            print(symptom.desc)
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell") as! CalendarTableViewCell
        if let frc = fetchedResultsController, let count =  frc.fetchedObjects?.count{
            if count > 0{
                let object = frc.object(at: indexPath)
                configureCell(cell: cell, object: object)
                return cell
            }

        }
        cell.titleLabel.isHidden = true
        cell.descriptionLabel.isHidden = false
        cell.descriptionLabel.text = "No Events To Show"
        cell.timeLabel.isHidden = true
        cell.symptomIcon.isHidden = true
        cell.typeIndicator.isHidden = true
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 1
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }
}
