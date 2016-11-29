//
//  CalendarViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/12/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for calendar and sets up a controller to handle input from user (e.g. date selection)

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
    
    //Retrieves the context for the app to access stored data
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    
    // Fetches information about symptoms from stored data
    let symptomsFetchRequest: NSFetchRequest<Symptom> = {
        let fetchRequest = NSFetchRequest<Symptom>(entityName: "Symptom")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        return fetchRequest
    }()
    
    let appointmentsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Appointment")
    var fetchedSymptomsForSelectedDate = [Symptom]()
    
    // Sets up the calendar and table view
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
    // Reloads calendar view after the view appears to user
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.reloadData()
    }
    
    // Updates list of symptos right before the view reappears to user
    override func viewWillAppear(_ animated: Bool) {
        updateSymptomList(forDate: f.string(from: self.presentedDate))
        super.viewWillAppear(animated)
    }
    
    // Responds to users click by switching the calendar to the next month
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
    
        // Responds to users click by switching the calendar to the previous month
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
    
    //Sets the labels describing the currently showing calendar
    func setupViewsOfCalendar(startDate: Date) {
        presentedMonth = NSCalendar.current.component(.month, from: startDate)
        let monthName = formatter.monthSymbols[(presentedMonth-1)] // 0 indexed array
        presentedYear = NSCalendar.current.component(.year, from: startDate)
        monthLabel.text = monthName.uppercased()
        yearLabel.text = String(presentedYear)
    }
    
    // Takes a date and fetches the list of symptoms that occur on the date
    func symptomsForDate(date: String) -> [Symptom]? {
        let fetchRequest = symptomsFetchRequest
        fetchRequest.predicate = NSPredicate(format: "date== %@", date)
        do{
            let symptoms = try managedContext.fetch(fetchRequest)
            print("Fetch succeeded")
            return symptoms
        }
        catch{
            print("Fetch failed")
            return nil
        }
    }
}

//MARK: JTCalendar Methods
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    

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
    
    // Sets up the calendar cells
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let cell = cell as! CellView
        
        cell.setupCellBeforeDisplay(cellState: cellState, date: date)
        guard let symptoms = symptomsForDate(date: f.string(from: date)), symptoms.count > 0 else {
            cell.eventIndicator.isHidden = true
            return
        }
        cell.eventIndicator.isHidden = false
    }
    
    // Configures the calendar for the month switched to
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendar.reloadData()
        
    }
    
    // Sets the color indicators for days in the currently showing month and the day currently selected
    /*
     * handl
     */
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState, date: Date) {
        guard let cell = view as? CellView  else {
            return
        }
        if !formatter.string(from: date).isEqual(todayDate) {
            if cellState.isSelected {
                cell.dayLabel.textColor = UIColor(hexString: "85CEC4")
            } else {
                if cellState.dateBelongsTo == .thisMonth {
                    cell.dayLabel.textColor = UIColor.white
                } else {
                    cell.dayLabel.textColor = UIColor.lightGray
                }
            }
        }
        
    }
    // When a user selects date, this will retrieve the symptoms on the day for the table view and show that the day is selected
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        print("Cell selected at \(date)")
        updateSymptomList(forDate: f.string(from: date))
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
    
    // When a day is deselected, the color of the day label will go back to normal
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState, date: date)
    }
}

//Mark: Table View
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    
    // Creates a lists indicating that symtoms exist on the currently selected day
    func updateSymptomList(forDate date: String) {
        fetchedSymptomsForSelectedDate = symptomsForDate(date: date) ?? []
        tableView.reloadData()
    }
    
    // Sets labels of the table view cell with proper information
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
        }
    }
    
    // Sets up each table cell specific to the symptom it is associated with
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CalendarTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarEventCell") as! CalendarTableViewCell
        let symptom = fetchedSymptomsForSelectedDate[indexPath.row]
        configureCell(cell: cell, object: symptom)
        return cell
    }
    
    // Sets the number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Sets the number of rows to be however many symptoms are set for a specific date
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedSymptomsForSelectedDate.count
    }
}
