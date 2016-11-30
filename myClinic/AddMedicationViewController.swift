//
//  AddMedicationViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/28/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for adding medication details and managing user interaction (e.g. adding a date to medication occurance)

import UIKit
import CoreData

/// Function to send info back to MedicationsViewController
typealias AddMedicationCallback = (_ location: String, _ date: Date) -> Void

class AddMedicationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    
    var selectedDate: Date!
    var addMedicationCallback: AddMedicationCallback!
    
    /// Retrieves the context for the app to access stored data
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // General date picker set up when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
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
    
    /// Saves medication to managed context
    func saveMedication() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    /// Sets the selected time upon user's action
    ///
    /// - parameter sender: time picker
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = datePicker.date

    }

    /// Dimisses view. Kicks back to Log View Controller
    ///
    /// - parameter sender: button being pressed
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }
    
    /// Creates a new Medication entity with its name and refill date and sends user back to Medications View Controller
    ///
    /// - parameter sender: the button being pressed
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let entity =  NSEntityDescription.entity(forEntityName: "Medication",
                                                 in:managedContext)
        let newMedication = Medication(entity: entity!,
                                         insertInto: managedContext)
        
        newMedication.name = nameTextField.text
        newMedication.date = selectedDate as NSDate?
        saveMedication()
        self.dismiss(animated: true, completion: nil)
    }
}
