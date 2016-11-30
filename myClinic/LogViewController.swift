//
//  LogViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for logging symptoms and managing user interaction (e.g. selecting a symptom that occured)
// Saves to CoreData managed context
// Will in the future notify user when saved and kick user back to calendar

import UIKit
import CoreData


/// Stores string in easy to use containers to avoid spelling mistakes
enum SymptomDesc: String {
    case Headache = "Headache", Dizziness = "Dizziness", Fever = "Fever", Nausea = "Nausea", Sleeplessness = "Sleeplessness", Diarrhea = "Diarrhea", Constipation = "Constipation"
}
class LogViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var loggedSymptoms = [Symptom]()
    
    
    /// Dictionary of symptoms. Gives info about whether it has been selected, holds its description and time
    var symptoms:[String:(Bool,String,Date)] = [SymptomDesc.Headache.rawValue:(false,"", Date()),
                                                SymptomDesc.Dizziness.rawValue:(false,"", Date()),
                                                SymptomDesc.Fever.rawValue:(false,"", Date()),
                                                SymptomDesc.Nausea.rawValue:(false,"", Date()),
                                                SymptomDesc.Sleeplessness.rawValue:(false,"", Date()),
                                                SymptomDesc.Diarrhea.rawValue:(false,"", Date()),
                                                SymptomDesc.Constipation.rawValue:(false,"", Date())]
    
    /// Retrieves managed context from app delegate
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    /// Sets date format
    lazy var f : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        
        return f
    }()
    
    var presentedDate = Date()
    var newSymptomTime: Date?
    var newSymptomDesc: String?
    
    /// Sets date label
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
        dateLabel.text = f.string(from:presentedDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Increments presented day by one day
    ///
    /// - parameter sender: the button being pressed
    @IBAction func nextDayButtonPressed(_ sender: UIButton) {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: presentedDate){
            presentedDate = date
            print(presentedDate)
            dateLabel.text = f.string(from:presentedDate)
        }
    }
    
    /// Decrements presented day by one day
    ///
    /// - parameter sender: the button being pressed
    @IBAction func lastDayButtonPressed(_ sender: UIButton) {
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: presentedDate){
            presentedDate = date
            print(presentedDate)
            
            dateLabel.text = f.string(from:presentedDate)
        }
    }
    
    
    /// Creates a new Symptom entity with its name, description, date and time.
    ///
    /// - parameter sender: the button being pressed
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        for (symptom, info) in symptoms {
            if info.0 {
                let entity =  NSEntityDescription.entity(forEntityName: "Symptom",
                                                         in:managedContext)
                let newSymptom = Symptom(entity: entity!,
                                         insertInto: managedContext)
                newSymptom.name = symptom
                newSymptom.desc = info.1
                newSymptom.time = info.2 as NSDate
                f.dateFormat = "yyyy MM dd"
                newSymptom.date = f.string(from: presentedDate)
            }
        }
        saveSymptoms()
    }
    
    
    /// Saves current changes to the managed context
    func saveSymptoms() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    /// Sets up function to retrieve time and description from symptom details view controller
    ///
    /// - parameter segue:  segue to view that is taken
    /// - parameter sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSymptomDetail" {
            let destinationVC = segue.destination as! EditSymptomViewController
            destinationVC.userAdditionCallback = { time, desc in
                self.symptoms[sender as! String]?.2 = time
                self.symptoms[sender as! String]?.1 = desc!
            }
        }
    }
    
}

// MARK: Table View Methods
extension LogViewController: UITableViewDelegate,UITableViewDataSource{
    
    
    /// Sets up cell for row being modified
    ///
    /// - parameter tableView: table view
    /// - parameter indexPath: cell indicator
    ///
    /// - returns: cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LogTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell") as! LogTableViewCell
        cell.symptomLabel.text = Array(symptoms.keys)[indexPath.item]
        return cell
        
    }
    
    /// Sets the number of sections in table view
    ///
    /// - parameter tableView: table view
    ///
    /// - returns: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///  Sets the number of rows to be however many symptoms are set for a specific date
    ///
    /// - parameter tableView: table view
    /// - parameter section:   the section
    ///
    /// - returns: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    
    /// Shows/hides checkmark when symptom is selected and sends user to edit symptom detail view
    ///
    /// - parameter tableView: table view
    /// - parameter indexPath: cell indicator
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LogTableViewCell
        cell.selectedCheck.isHidden = !cell.selectedCheck.isHidden
        cell.selectedView.isHidden = !cell.selectedView.isHidden
        
        guard let symptom = cell.symptomLabel.text else {
            return
        }
        if let isChecked = symptoms[symptom]?.0 {
            symptoms[symptom]?.0 = !isChecked
        }
        performSegue(withIdentifier: "ToSymptomDetail", sender: symptom)
    }
    
}
