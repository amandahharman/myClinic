//
//  MedicationsViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/28/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import CoreData

class MedicationsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    let medicationsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Medication")
    
    var newName: String?
    var newDate: Date?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        print(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
        fetchRequest(request: medicationsFetchRequest)
        tableview.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        tableview.reloadData()
    }
    
    func fetchRequest(request: NSFetchRequest<NSFetchRequestResult>){
        let  fetchRequest = request
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = [primarySortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request as! NSFetchRequest<NSManagedObject>,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController?.delegate = self
        
        do{
            try
                fetchedResultsController?.performFetch()
            print("Fetch succeeded")
        }
        catch{
            print("Fetch failed")
        }
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddMedication", sender: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddMedication"{
            let destinationVC = segue.destination as! AddMedicationViewController
            destinationVC.addMedicationCallback = { name, date in
                self.newDate = date
                self.newName = name
            }
        }
    }


}

extension MedicationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableview.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableview.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            
            guard let indexPath = indexPath ,let cell = tableview.cellForRow(at: indexPath) else {return}
            
            configureCell(cell: cell, object: controller.object(at: indexPath) as! NSManagedObject)
            
            tableview.reloadRows(at: [indexPath], with: .fade)
            
            
        case .move:
            tableview.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            tableview.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableview.insertSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableview.deleteSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.endUpdates()
    }
    
}


extension MedicationsViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 1
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationsCell") as! MedicationTableViewCell
        if let object = fetchedResultsController?.object(at: indexPath ){
            configureCell(cell: cell, object: object)
            return cell
        }
        cell.medicationNameLabel.text = "No medications to show"
        return cell
    }
    
    
    
    @nonobjc func tableView(_tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func configureCell(cell: UITableViewCell, object: NSManagedObject){
        if let cell = cell as? MedicationTableViewCell {
            if let medication = object as? Medication{
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                formatter.timeStyle = .none
                cell.refillDateLabel.text = "Refill on" + formatter.string(from: medication.date as! Date)
                cell.medicationNameLabel.text = medication.name
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action , indexPath) -> Void in
            if let record = self.fetchedResultsController?.object(at: indexPath){
                self.managedContext.delete(record)}
            
        })
        
        return [deleteAction]
        
    }
    
    
}

