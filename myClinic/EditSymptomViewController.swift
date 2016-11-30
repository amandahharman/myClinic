//
//  EditSymptomViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/21/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for adding symptom details and managing user interaction (e.g. adding a time to symptom occurance)


import UIKit


/// Function to send info back to LogViewController
typealias UserAdditionCallback = (_ time:Date, _ desc: String?) -> Void

class EditSymptomViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var noteField: UITextField!
    var selectedTime: Date!
    var userAdditionCallback: UserAdditionCallback!
    
    
    /// General set up
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noteField.delegate = self
        timePicker.datePickerMode = UIDatePickerMode.time
        timePicker.setValue(UIColor.white, forKeyPath: "textColor")
        selectedTime = timePicker.date
    }
    
    
    /// Dismisses keyboard upon hitting return key
    ///
    /// - parameter textField: the text field being used
    ///
    /// - returns: bool exit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    /// Sets the selected time upon user's action
    ///
    /// - parameter sender: time picker
    @IBAction func timeChanged(_ sender: AnyObject) {
        selectedTime = timePicker.date
    }
    
    
    /// Dimisses view. Kicks back to Log View Controller
    ///
    /// - parameter sender: button being pressed
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Dimisses view and sends selected time and new description back to Log View Controller
    ///
    /// - parameter sender: button being pressed
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        userAdditionCallback(selectedTime,noteField.text! )
        self.dismiss(animated: true, completion: nil)
    }

}
