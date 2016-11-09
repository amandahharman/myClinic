//
//  DataMangaer.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T?)
    case Error(NSError)
}

class DataManager {
    
    static let sharedInstance = DataManager()

    let patientURL = ""
    var user: Patient?
    
    func getUser(id: String, completion: (Result<Patient>) -> ()) {
        NetworkManager.sharedInstance.getArrayOfData(endpoint: patientURL) { (result, error) in
            if let patientData = result {
                for patient in patientData{
                    self.user = Patient(
                        patientID: patient["patientID"] as! Int,
                        lastName: patient["lastName"] as! String,
                        firstName: patient["firstName"] as! String,
                        address: patient["address"] as! String,
                        city: patient["city"] as! String,
                        state: patient["state"] as! String,
                        zip: patient["zip"] as! Int,
                        phoneNumber: patient["phoneNumber"] as! String,
                        accountBalance: patient["accountBalance"] as! Double,
                        attendingPhysicianID: patient["attendingPhysicianID"] as! Int
                    )
                }
                completion(.Success(self.user))
            }
            else {
                completion(.Error(error!))
            }
        }
    }

}
