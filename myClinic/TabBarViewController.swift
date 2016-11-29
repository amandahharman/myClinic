//
//  TabBarViewController.swift
//  myClinic
//
//  Created by Amanda Harman on 11/14/16.
//  Copyright © 2016 Amanda Harman. All rights reserved.
//
// Modifies appearance of the Tab Bar

import UIKit

//
class TabBarViewController: UITabBarController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
//        // Sets the default color of the icon of the selected UITabBarItem and Title
        UITabBar.appearance().tintColor = UIColor(hexString: "85cec4")
    }
}
