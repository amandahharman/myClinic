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

    
    @IBOutlet weak var tableView: UITableView!
    var loggedSymptoms = [NSManagedObject]()
    var headacheLogged: Symptom?
    var dizzinessLogged: Symptom?
    var feverLogged: Symptom?
    var nauseaLogged: Symptom?
    var sleeplessnessLogged: Symptom?
    var diarrheaLogged: Symptom?
    var constipationLogged: Symptom?
    
    let symptoms:[String] = [SymptomDesc.Headache.rawValue, SymptomDesc.Dizziness.rawValue, SymptomDesc.Fever.rawValue, SymptomDesc.Nausea.rawValue, SymptomDesc.Sleeplessness.rawValue, SymptomDesc.Diarrhea.rawValue, SymptomDesc.Constipation.rawValue]
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let headacheLogged = headacheLogged {
            self.saveSymptom(symptom: headacheLogged)
        }
        if let dizzinessLogged = dizzinessLogged {
            self.saveSymptom(symptom: dizzinessLogged)
        }
        if let feverLogged = feverLogged {
            self.saveSymptom(symptom: feverLogged)
        }
        if let nauseaLogged = nauseaLogged {
            self.saveSymptom(symptom: nauseaLogged)
        }
        if let sleeplessnessLogged = sleeplessnessLogged {
            self.saveSymptom(symptom: sleeplessnessLogged)
        }
        if let diarrheaLogged = diarrheaLogged {
            self.saveSymptom(symptom: diarrheaLogged)
        }
        if let constipationLogged = constipationLogged {
            self.saveSymptom(symptom: constipationLogged)
        }
        self.tableView.reloadData()
    }
    
    func saveSymptom(symptom: Symptom) {
        let entity =  NSEntityDescription.entity(forEntityName: "Symptom",
                                                 in:managedContext)
        let newSymptom = NSManagedObject(entity: entity!,
                                     insertInto: managedContext)
        newSymptom.setValue(symptom.name, forKey: "symptom")
        newSymptom.setValue(symptom.description, forKey: "desc")
        newSymptom.setValue(symptom.date, forKey: "date")
  
        do {
            try managedContext.save()
            loggedSymptoms.append(newSymptom)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
   

}

extension LogViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:LogTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell") as! LogTableViewCell
        cell.symptomLabel.text = symptoms[indexPath.item]
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

        if cell.selectedCheck.isHidden == true {
            if cell.symptomLabel.isEqual(SymptomDesc.Headache.rawValue){
                headacheLogged = Symptom(name: SymptomDesc.Headache.rawValue, description: nil, date: Date())
            }
        }
       if cell.selectedCheck.isHidden == false {
            if cell.symptomLabel.isEqual(SymptomDesc.Headache.rawValue){
                headacheLogged = nil
            }
        }

    }
}
