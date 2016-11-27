//
//  AddAppointmentViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/26/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import CoreData

typealias AddAppointmebtCallback = (_ location: String, _ date: Date) -> Void

class AddAppointmentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    var selectedDate: Date!
    var addAppointmentCallback: AddAppointmebtCallback!
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

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
                selectedDate = datePicker.date
    }
    
    func saveAppointment() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
//        self.addAppointmentCallback(locationTextField.text!, selectedDate)
        let entity =  NSEntityDescription.entity(forEntityName: "Appointment",
                                                 in:managedContext)
        let newAppointment = Appointment(entity: entity!,
                                         insertInto: managedContext)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        newAppointment.name = "Doctor Appointment"
        newAppointment.date = selectedDate as NSDate?
        newAppointment.location = locationTextField.text
        saveAppointment()
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
                self.dismiss(animated: true, completion: nil)
    }

}
