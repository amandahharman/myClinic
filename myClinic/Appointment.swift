//
//  Appointment.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation

struct Appointment{
    var patientID: Int
    var physicianID: Int
    var scheduledDate: Date
    var scheduledTime: Date
    var diagnosisID: Int?
}
