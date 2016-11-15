//
//  TabBarViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        
        // Sets the default color of the icon of the selected UITabBarItem and Title
        UITabBar.appearance().tintColor = UIColor.white
        // Sets the default color of the background of the UITabBar
        UITabBar.appearance().barTintColor = UIColor(hexString: "ea5370")
    }
}
