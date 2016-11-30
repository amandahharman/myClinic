//
//  AddAppointmentViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/26/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for adding appointment details and managing user interaction (e.g. adding a date to appointment occurance)

import UIKit
import CoreData

/// Function to send info back to AppointmentsViewControlelr
typealias AddAppointmebtCallback = (_ location: String, _ date: Date) -> Void

class AddAppointmentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    var selectedDate: Date!
    var addAppointmentCallback: AddAppointmebtCallback!
    
    /// Retrieves the context for the app to access stored data
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    // General date picker set up when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextField.delegate = self
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        selectedDate = datePicker.date
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
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
                selectedDate = datePicker.date
    }
    
    
    /// Saves appointment to managed context
    func saveAppointment() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /// Creates a new Appointment entity with its location and date and sends user back to Appointments View Controller
    ///
    /// - parameter sender: the button being pressed
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let entity =  NSEntityDescription.entity(forEntityName: "Appointment",
                                                 in:managedContext)
        let newAppointment = Appointment(entity: entity!,
                                         insertInto: managedContext)

        newAppointment.name = "Doctor Appointment"
        newAppointment.date = selectedDate as NSDate?
        newAppointment.location = locationTextField.text
        saveAppointment()
        self.dismiss(animated: true, completion: nil)

    }
    
    /// Dimisses view. Kicks back to Log View Controller
    ///
    /// - parameter sender: button being pressed
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
                self.dismiss(animated: true, completion: nil)
    }

}
