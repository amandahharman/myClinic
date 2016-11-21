//
//  LogViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import CoreData

enum SymptomDesc: String {
    case Headache = "Headache", Dizziness = "Dizziness", Fever = "Fever", Nausea = "Nausea", Sleeplessness = "Sleeplessness", Diarrhea = "Diarrhea", Constipation = "Constipation"
}
class LogViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var loggedSymptoms = [Symptom]()
    
    
    var symptoms:[String:Bool] = [SymptomDesc.Headache.rawValue:false,
                                  SymptomDesc.Dizziness.rawValue:false,
                                  SymptomDesc.Fever.rawValue:false,
                                  SymptomDesc.Nausea.rawValue:false,
                                  SymptomDesc.Sleeplessness.rawValue:false,
                                  SymptomDesc.Diarrhea.rawValue:false,
                                  SymptomDesc.Constipation.rawValue:false]
    
    var symptomSelected: Symptom?
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    lazy var f : DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        
        return f
    }()
    
    var presentedDate = Date()
    var newSymptomTime: Date?
    var newSymptomDesc: String?
    
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
    
    @IBAction func nextDayButtonPressed(_ sender: UIButton) {
        if let date = Calendar.current.date(byAdding: .day, value: 1, to: presentedDate){
            presentedDate = date
            print(presentedDate)
            dateLabel.text = f.string(from:presentedDate)
        }
    }
    
    @IBAction func lastDayButtonPressed(_ sender: UIButton) {
        if let date = Calendar.current.date(byAdding: .day, value: -1, to: presentedDate){
            presentedDate = date
            print(presentedDate)
            
            dateLabel.text = f.string(from:presentedDate)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        for (symptom, selected) in symptoms {
            if selected {
                let entity =  NSEntityDescription.entity(forEntityName: "Symptom",
                                                         in:managedContext)
                let newSymptom = Symptom(entity: entity!,
                                         insertInto: managedContext)
                newSymptom.name = symptom
                f.dateFormat = "yyyy MM dd"
                newSymptom.date = f.string(from: presentedDate)
                newSymptom.desc = newSymptomDesc
                newSymptom.time = newSymptomTime as NSDate?
                loggedSymptoms.append(newSymptom)
                
            }
        }
        saveSymptoms()
    }
    
    func saveSymptoms() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSymptomDetail"{
            let destinationVC = segue.destination as! EditSymptomViewController
            destinationVC.userCallback = { time, desc in
                self.newSymptomTime = time
                self.newSymptomDesc = desc
            }
        }
    }
    
}

extension LogViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LogTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell") as! LogTableViewCell
        cell.symptomLabel.text = Array(symptoms.keys)[indexPath.item]
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symptoms.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! LogTableViewCell
        cell.selectedCheck.isHidden = !cell.selectedCheck.isHidden
        cell.selectedView.isHidden = !cell.selectedView.isHidden
        if let symptom = cell.symptomLabel.text {
            if let isChecked = symptoms[symptom] {
                symptoms[symptom] = !isChecked
            }
        }
        performSegue(withIdentifier: "ToSymptomDetail", sender: nil)
    }
    
}
