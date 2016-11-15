//
//  CalendarEvent.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation

class CalendarEvent {
    var appointment: Appointment?
    var symptom: Symptom?
    var description: String?
    var startDate: String
    
    init(appointment: Appointment, date: String) {
        self.appointment = appointment
        self.startDate = date
    }
    
    init(symptom: Symptom, description: String, date: String ) {
        self.symptom = symptom
        self.description = description
        self.startDate = date 
    }
}
