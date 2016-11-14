//
//  HomeViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    let user = Patient(patientID: 01, lastName: "Harman", firstName: "Amanda", address: "123 Hunt Club Rd", city: "Wilmington", state: "NC", zip: 28403, phoneNumber: "919-671-7072", accountBalance: 1000.23 , attendingPhysicianID: 10, age: 21, weight: 130, height: "5 ft 5 in" )

    let physician = Physician(physicianID: 10, lastName: "Doe", firstName: "John", address: "321 Main St", city: "Wilmington", state: "NC", zip: 28403, businessPhoneNumber: "111-111-1111", homePhoneNumber: nil)

}
