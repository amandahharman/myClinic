//
//  Diagnosis.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation

struct Diagnosis {
    var diagnosisID: Int
    var diagnosisName: String
    var associatedSymptomID: [Int]?
    var associatedPerscriptionID: Int?
}
