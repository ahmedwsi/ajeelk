//
//  HomeVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController , UITableViewDelegate    {

    @IBOutlet weak var avaImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var SettingsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if user != nil {
        // get user details from user variable
        appDelegate.circularImage(photoImageView:  avaImg)
        let profileـusername = user!["full_name"] as! String
        let profileـemail    = user!["email"] as! String
        let profileـpic      = user!["pic"] as! String
        
        usernameLbl.text = profileـusername
        emailLbl.text    = profileـemail
        
        if (profileـpic == "no_pic") {
            // url path to image
            avaImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_user.png"))
        }else{
            // url path to image
            
            avaImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/users/\(profileـpic)"))
            
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if user != nil {
        let profileـusername = user!["full_name"] as! String
        let profileـemail    = user!["email"] as! String
        let profileـpic      = user!["pic"] as! String
        
        usernameLbl.text = profileـusername
        emailLbl.text    = profileـemail
        
        if (profileـpic == "no_pic") {
            // url path to image
            avaImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_user.png"))
        }else{
            // url path to image
            
            avaImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/users/\(profileـpic)"))
            
        }
        }
    }
    

    
    // logout button
    @IBAction func logout_click(_ sender: Any) {
        // remove saved information
        UserDefaults.standard.removeObject(forKey: "parseJSON")
        UserDefaults.standard.synchronize()
        
        // go to login page
        let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.present(loginvc, animated: true, completion: nil)
    }
    
    


}


