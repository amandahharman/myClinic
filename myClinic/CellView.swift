//
//  CellView.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Formats Cell View for calendar and hooks up elements to UI

import UIKit
import JTAppleCalendar


class CellView: JTAppleDayCellView {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet var dayLabel: UILabel!
    
    @IBOutlet weak var eventIndicator: UIImageView!

/// Gets today's day and sets the string format
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
    
    /// Sets up the initial state of cell of calendar including the colors and the labels
    ///
    /// - parameter cellState: where te cell is in context of calendar
    /// - parameter date:      date of cell being modified
    func setupCellBeforeDisplay(cellState: CellState, date: Date) {
        dayLabel.text =  cellState.text
        if cellState.dateBelongsTo == .thisMonth{
            self.dayLabel.textColor = UIColor.white
        } else {
            self.dayLabel.textColor = UIColor.lightGray
        }
        
        selectedView.backgroundColor = UIColor(hexString: "85CEC4")

        
        eventIndicator.isHidden = true
        selectedView.isHidden = true
        selectedView.isHidden = true
        if formatter.string(from: date).isEqual(todayDate) {
            selectedView.backgroundColor = UIColor(hexString: "85CEC4")
            selectedView.isHidden = false
        }
        
        
    }



}
