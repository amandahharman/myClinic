//
//  MedicationsViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/28/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for reporting medications and managing user interaction (e.g. deleting record)


import UIKit
import CoreData

class MedicationsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    
    /// Retrieves managed context from app delegate
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    /// Controller to help manage fetched object
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    /// Request to use for medications
    let medicationsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Medication")
    
    var newName: String?
    var newDate: Date?

    /// General table set up. Requests already existing medication data
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        print(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
        fetchRequest(request: medicationsFetchRequest)
        tableview.reloadData()
    }

    /// Reloads table view upon view appearance
    override func viewDidAppear(_ animated: Bool) {
        tableview.reloadData()
    }
    
    /// Fetches objects pertaining to fetch request
    ///
    /// - parameter request: which entity is of interest
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

    /// Directs user to add medication page
    ///
    /// - parameter sender: button being pressed
    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddMedication", sender: nil)

    }
    
    /// Sets up function to retrieve location and date from medications details view controller
    ///
    /// - parameter segue:  segue to view that is taken
    /// - parameter sender: sender
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

// Mark: Fetched Result Controller Methods
extension MedicationsViewController: NSFetchedResultsControllerDelegate {
    
    /// Signal to table view that updates are about to occur
    ///
    /// - parameter controller: controller instance
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.beginUpdates()
    }
    
    /// Updates table view upon insert, delet, update, or move in the database
    ///
    /// - parameter controller:   controller
    /// - parameter anObject:     the object
    /// - parameter indexPath:    cell indicator
    /// - parameter type:         type of change being made
    /// - parameter newIndexPath: new position
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
    
    /// Section did change instructions
    ///
    /// - parameter controller:   controller
    /// - parameter sectionInfo:  the section info
    /// - parameter sectionIndex: section indicator
    /// - parameter type:         type of change being made
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
    
    /// Tells table view to end updates
    ///
    /// - parameter controller: controller
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableview.endUpdates()
    }
    
}

// MARK: Table View Methods
extension MedicationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// Sets the number of sections in table view
    ///
    /// - parameter tableView: table view
    ///
    /// - returns: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    ///  Sets the number of rows to be however many symptoms are set for a specific date
    ///
    /// - parameter tableView: table view
    /// - parameter section:   the section
    ///
    /// - returns: number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 1
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }
    
    /// Sets up each table cell specific to the medication object it is associated with
    ///
    /// - parameter tableView: table view to be modified
    /// - parameter indexPath: cell specifier
    ///
    /// - returns: cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationsCell") as! MedicationTableViewCell
        if let object = fetchedResultsController?.object(at: indexPath ){
            configureCell(cell: cell, object: object)
            return cell
        }
        cell.medicationNameLabel.text = "No medications to show"
        return cell
    }
    
    
    
    /// Allows editing of rows
    ///
    /// - parameter _tableView: the table view
    /// - parameter indexPath:  cell index
    ///
    /// - returns: true
    @nonobjc func tableView(_tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /// Sets labels of the table view cell with proper information
    ///
    /// - parameter cell:   cell to be modified
    /// - parameter object: the data object retrieved that wil populate the cell
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
    
    
    
    /// Deletes object in managed context if row in table is deleted
    ///
    /// - parameter tableView: table view
    /// - parameter indexPath: index to be deleted
    ///
    /// - returns: delete action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action , indexPath) -> Void in
            if let record = self.fetchedResultsController?.object(at: indexPath){
                self.managedContext.delete(record)}
            
        })
        
        return [deleteAction]
        
    }
    
    
}

