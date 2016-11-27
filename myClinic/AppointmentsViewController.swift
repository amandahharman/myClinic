//
//  AppointmentsViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/21/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit
import CoreData

class AppointmentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    let appointmentsFetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "Appointment")
    
    var newLocation: String?
    var newDate: Date?
    var newTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
        fetchRequest(request: appointmentsFetchRequest)
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
        performSegue(withIdentifier: "toAddAppointment", sender: nil)        
    }
    
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

extension AppointmentsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}



extension AppointmentsViewController: UITableViewDataSource, UITableViewDelegate{
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsCell") as! AppointmentsTableViewCell
            if let object = fetchedResultsController?.object(at: indexPath ){
                configureCell(cell: cell, object: object)
                return cell
            }
            cell.locationLabel.text = "No appointments to show"
            return cell
        }
        
   
    
    @nonobjc func tableView(_tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func configureCell(cell: UITableViewCell, object: NSManagedObject){
        if let cell = cell as? AppointmentsTableViewCell {
            if let appointment = object as? Appointment{
                cell.dateLabel.text = appointment.date?.description
                cell.locationLabel.text = appointment.location
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

