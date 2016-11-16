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
        
        selectedView.backgroundColor = UIColor(hexString: "85CEC4")

        

        selectedView.isHidden = true
        selectedView.isHidden = true
        if formatter.string(from: date).isEqual(todayDate) {
            selectedView.backgroundColor = UIColor(hexString: "85CEC4")
            selectedView.isHidden = false
        }
        
        
    }



}
