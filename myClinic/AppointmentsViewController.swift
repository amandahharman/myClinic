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
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "AppointmentsCell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @IBAction func addButtonPressed(_ sender: UIButton) {
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

    extension AppointmentsViewController: UITableViewDataSource, UITableViewDelegate{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let sections = fetchedResultsController?.sections else {
                return 0
            }
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsCell"){
                 if let object = fetchedResultsController?.object(at: indexPath ){
                configureCell(cell: cell, object: object)
                }
            
            return cell
            }
            return UITableViewCell()
        }
        
        @nonobjc func tableView(_tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
        }
        
        func configureCell(cell: UITableViewCell, object: NSManagedObject){
            if let appointment = object as? Appointment{
                cell.dateLabel.text = appointment.date
                cell.locationLabel.text = ""
            
            }
            
        }
        
        
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController?.sections?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let sections = fetchedResultsController?.sections else {return nil}
            let currentSection = sections[section]
            return currentSection.name
        }

    }

