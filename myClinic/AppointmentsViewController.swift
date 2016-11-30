//
//  AppointmentsViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/21/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Sets up view for reporting appointments and managing user interaction (e.g. deleting record)


import UIKit
import CoreData

class AppointmentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Retrieves managed context from app delegate
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    /// Controller to help manage fetched object
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    
    /// Request to use for appointments
    let appointmentsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Appointment")
    
    var newLocation: String?
    var newDate: Date?
    var newTime: Date?
    
    
    /// General table set up. Requests already existing appointment data
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
        fetchRequest(request: appointmentsFetchRequest)
        tableView.reloadData()
        
    }
    
    /// Reloads table view upon view appearance
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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

    
    /// Directs user to add appointment page
    ///
    /// - parameter sender: button being pressed
    @IBAction func addButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toAddAppointment", sender: nil)        
    }
    
    /// Sets up function to retrieve location and date from appointment details view controller
    ///
    /// - parameter segue:  segue to view that is taken
    /// - parameter sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddAppointment"{
            let destinationVC = segue.destination as! AddAppointmentViewController
            destinationVC.addAppointmentCallback = { location, date in
                self.newDate = date
                self.newLocation = location
            }
        }
    }
    

}

// Mark: Fetched Result Controller Methods
extension AppointmentsViewController: NSFetchedResultsControllerDelegate {
    
    
    /// Signal to table view that updates are about to occur
    ///
    /// - parameter controller: controller instance
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
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
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .update:
            
            guard let indexPath = indexPath ,let cell = tableView.cellForRow(at: indexPath) else {return}
            
            configureCell(cell: cell, object: controller.object(at: indexPath) as! NSManagedObject)
            
            tableView.reloadRows(at: [indexPath], with: .fade)
            
            
        case .move:
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
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
            tableView.insertSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index:sectionIndex) as IndexSet, with: .fade)
        default:
            break
        }
    }
    
    /// Tells table view to end updates
    ///
    /// - parameter controller: controller 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}


// MARK: Table View Methods
extension AppointmentsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    /// Sets up each table cell specific to the appointment object it is associated with
    ///
    /// - parameter tableView: table view to be modified
    /// - parameter indexPath: cell specifier
    ///
    /// - returns: cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsCell") as! AppointmentsTableViewCell
            if let object = fetchedResultsController?.object(at: indexPath ){
                configureCell(cell: cell, object: object)
                return cell
            }
            cell.locationLabel.text = "No appointments to show"
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
        if let cell = cell as? AppointmentsTableViewCell {
            if let appointment = object as? Appointment{
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                formatter.timeStyle = .short
                cell.dateLabel.text = formatter.string(from: appointment.date as! Date)
                cell.locationLabel.text = appointment.location
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

