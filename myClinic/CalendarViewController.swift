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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "yyyy MM dd"
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        self.calendarView.scrollEnabled = false
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: false, animateScroll: false) {
            self.presentedDate = Date()
            self.setupViewsOfCalendar(startDate: self.presentedDate)
        }
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
        monthLabel.text = monthName
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
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = UIColor.black
        } else {
            myCustomCell.dayLabel.textColor = UIColor.gray
        }
    }

}
