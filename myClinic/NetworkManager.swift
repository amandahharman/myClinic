//
//  NetworkManager.swift
//  myClinic
//
//  Created by Amanda Harman on 11/9/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

//Only place we will need swifty JSON and Alamofire
class NetworkManager{

    static let sharedInstance = NetworkManager()
    
    func getArrayOfData(endpoint: String, completion: (_ result: [[String:AnyObject]]?, _ error: NSError?) -> ()) {
    }
}
