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
    @IBOutlet weak var selectedCheck: UIImageView!
    

    
    @IBOutlet weak var symptomLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }


    @IBAction func addNoteButtonPressed(_ sender: UIButton) {
    }
}
