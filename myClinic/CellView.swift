//
//  CellView.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CellView: JTAppleDayCellView {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet var dayLabel: UILabel!
    var eventsOnThisDay = [CalendarEvent]()
    
    @IBOutlet weak var eventLine: UIImageView!
    
    lazy var todayDate : String = {
        [weak self] in
        let aString = self!.formatter.string(from: Date())
        return aString
        }()
    lazy var formatter : DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy MM dd"
        
        return f
    }()
 
    func setupCellBeforeDisplay(cellState: CellState, date: Date) {
        dayLabel.text =  cellState.text
        if cellState.dateBelongsTo == .thisMonth{
            self.dayLabel.textColor = UIColor.white
        } else {
            self.dayLabel.textColor = UIColor.lightGray
        }
        
        self.selectedView.layer.cornerRadius =  self.selectedView.frame.width  / 2
        selectedView.backgroundColor = UIColor.lightGray

        
        eventLine.isHidden = true
        selectedView.isHidden = true
        selectedView.isHidden = true
        if formatter.string(from: date).isEqual(todayDate) {
            dayLabel.textColor = UIColor.darkGray
        }
        
        
    }



}
