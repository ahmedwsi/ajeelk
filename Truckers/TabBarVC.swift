//
//  TabBarVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // color of item in tab bar controller
        self.tabBar.tintColor = UIColor.white
        
        
        
        self.selectedIndex = 0
        UserDefaults.standard.synchronize()
//        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
//        
//        
//        // if user is logged before, keep him login
        if user == nil {
            
            viewControllers?.remove(at:4)  
            viewControllers?.remove(at:3)
        }
        
        // color of background of tabbar
        self.tabBar.barTintColor =  appGreenColor
        
        
        // disable translucent
        self.tabBar.isTranslucent = false
        
        
        // color of text under tabbar
        //tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.black], for: .selected)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.white], for: .selected)
        
        // new color for all icons of tabbar controller
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageColor(UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)).withRenderingMode(.alwaysOriginal)
            }
        }

    }

}


// new class we created to refer to our icon in tabbar controller.
extension UIImage {
    
    // in this func we customize our UIImage - our icon
    func imageColor(_ color : UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

