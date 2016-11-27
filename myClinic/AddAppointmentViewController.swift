//
//  AddAppointmentViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/26/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

typealias AddAppointmebtCallback = (_ location: String, _ date: Date) -> Void

class AddAppointmentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    var selectedDate: Date!
    var addAppointmentCallback: AddAppointmebtCallback!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        selectedDate = datePicker.date
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.addAppointmentCallback(locationTextField.text!, selectedDate)
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
                self.dismiss(animated: true, completion: nil)
    }

}
