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
    
    
    var symptoms:[String:(Bool,String,Date)] = [SymptomDesc.Headache.rawValue:(false,"", Date()),
                                                SymptomDesc.Dizziness.rawValue:(false,"", Date()),
                                                SymptomDesc.Fever.rawValue:(false,"", Date()),
                                                SymptomDesc.Nausea.rawValue:(false,"", Date()),
                                                SymptomDesc.Sleeplessness.rawValue:(false,"", Date()),
                                                SymptomDesc.Diarrhea.rawValue:(false,"", Date()),
                                                SymptomDesc.Constipation.rawValue:(false,"", Date())]
    
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
    
    func saveSymptoms() {
        do {
            try managedContext.save()
            print("Saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
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
        
        guard let symptom = cell.symptomLabel.text else {
            return
        }
        if let isChecked = symptoms[symptom]?.0 {
            symptoms[symptom]?.0 = !isChecked
        }
        performSegue(withIdentifier: "ToSymptomDetail", sender: symptom)
    }
    
}
