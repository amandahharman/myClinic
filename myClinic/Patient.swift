//
//  Patient.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation

struct Patient{
    var patientID: Int
    var lastName: String
    var firstName: String
    var address: String
    var city: String
    var state: String
    var zip: Int
    var phoneNumber: String
    var accountBalance: Double
    var attendingPhysicianID: Int
    var age: Int?
    var weight: Double?
    var height: String?
}
