//
//  AddMedicationViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/28/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import CoreData


typealias AddMedicationCallback = (_ location: String, _ date: Date) -> Void

class AddMedicationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    
    var selectedDate: Date!
    var addMedicationCallback: AddMedicationCallback!
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        selectedDate = datePicker.date
      
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func saveMedication() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = datePicker.date

    }

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }

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
