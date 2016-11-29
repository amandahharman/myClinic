//
//  MedicationTableViewCell.swift
//  myClinic
//
//  Created by Amanda Harman on 11/28/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

class MedicationTableViewCell: UITableViewCell {

    @IBOutlet weak var medicationNameLabel: UILabel!
    @IBOutlet weak var refillDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
