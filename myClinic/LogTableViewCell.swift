//
//  LogTableViewCell.swift
//  myClinic
//
//  Created by Amanda Harman on 11/15/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    
    @IBOutlet weak var selectedCheck: UIButton!
    
    @IBOutlet weak var symptomLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



    @IBAction func symptomSelected(_ sender: UIButton) {
    }

    @IBAction func addNoteButtonPressed(_ sender: UIButton) {
    }
}
