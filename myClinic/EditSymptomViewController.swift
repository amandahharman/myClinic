//
//  EditSymptomViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/21/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

typealias UserAdditionCallback = (_ time:Date, _ desc: String?) -> Void

class EditSymptomViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var noteField: UITextField!
    var selectedTime: Date!
    var userCallback: UserAdditionCallback!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteField.delegate = self
        timePicker.datePickerMode = UIDatePickerMode.time
        selectedTime = timePicker.date
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    @IBAction func timeChanged(_ sender: AnyObject) {
        selectedTime = timePicker.date
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.userCallback(selectedTime, noteField.text)
        self.dismiss(animated: true, completion: nil)
    }

}
