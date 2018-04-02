//
//  NavVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class NavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // color of top nav controller.
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // color of buttons in nav controller
        self.navigationBar.tintColor = UIColor.white
        
        // color of nav controller , nav bar background
        self.navigationBar.barTintColor = appGreenColor
        
        // disable translucent
        self.navigationBar.isTranslucent = false
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
