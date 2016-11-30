//
//  LogTableViewCell.swift
//  myClinic
//
//  Created by Amanda Harman on 11/15/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Formats table view cell for symptoms and hooks up elements to UI

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var selectedCheck: UIImageView!
    @IBOutlet weak var symptomLabel: UILabel!
    
    // Disallows the highlighting of row selected
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
}
