//
//  SettingsTableVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/9/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {

    var count_u_trucks = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            self.tableView.isHidden = true
        }else{
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        CheckUserTrucks()
    }
    
    
    
    // func of loading trucks from server
    func CheckUserTrucks() {
        appDelegate.showIndicator()
        // accessing php file via url path
        let user_id         = user!["user_id"] as! String
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_user_trucks.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "user_id=\(user_id)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        let count_trucks = parseJSON["count_trucks"] as! Int
                        
                        //print(count_trucks)
                        if count_trucks == 1 {
                           
                            self.count_u_trucks = "1"
                            self.tableView.reloadData()
                        }else{
                            
                            self.count_u_trucks = "0"
                            self.tableView.reloadData()
                        }
                        
                        //print(self.count_u_trucks)
                        appDelegate.hideIndicator()
                        
                        
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                    appDelegate.hideIndicator()
                }
                
            })
            
            }.resume()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "AppPrivacy" {
                let showPageV = segue.destination as! ShowPageVC
                showPageV.pageId = "2"
            } else if segue.identifier == "ContactUs" {
                let showPageV = segue.destination as! ShowPageVC
                showPageV.pageId = "3"
            } else if segue.identifier == "WaraqatSponser" {
                let showPageV = segue.destination as! ShowPageVC
                showPageV.pageId = "4"
            }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if ((section == 1) && (self.count_u_trucks == "0")) {
            return 0
        } else if ((section == 1 && self.count_u_trucks != "0")) {
            return 5
        } else if (section == 0) {
            return 2
        } else if (section == 2) {
            return 3
        } else {
            return 1
        }
    }

    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        performSegue(withIdentifier: "WaraqatSponser", sender: self)
    }
    
}
