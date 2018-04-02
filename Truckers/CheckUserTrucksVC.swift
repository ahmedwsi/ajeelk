//
//  CheckUserTrucksVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 7/18/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class CheckUserTrucksVC: UIViewController {
    
    var count_u_trucks = ""
    
    var truck_id = ""
    @IBOutlet weak var ViewSubControllers: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewDidAppear(_ animated: Bool) {
        if user != nil {
            
            CheckUserTrucks()
            
        }
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
                                //print(user!)
                            //user!.setValue("1", forKey: "count_user_trucks")
                            //UserDefaults.standard.synchronize()
                            
                            self.count_u_trucks = "1"
                            
                            //print(user)
                        }else{
                                //print(user!)
                            //user!.setValue("0", forKey: "count_user_trucks")
                            //UserDefaults.standard.synchronize()
                            
                            self.count_u_trucks = "0"
                            
                        }
                        // get message from $returnArray["message"]
                        
                        
                        // if there is some message - post is made
                         appDelegate.hideIndicator()
                            
                            
                            if (self.count_u_trucks == "0") {

                                
                                let controller = self.storyboard!.instantiateViewController(withIdentifier: "NoTruckVC")
                                controller.view.frame = self.view.bounds;
                                controller.willMove(toParentViewController: self)
                                self.ViewSubControllers.addSubview(controller.view)
                                self.addChildViewController(controller)
                                controller.didMove(toParentViewController: self)
                                
                            } else {
                                self.truck_id = parseJSON["truck_id"] as! String
                                let controller = self.storyboard!.instantiateViewController(withIdentifier: "TruckDetailsVC") as! TruckDetailsVC
                                controller.truck_id = self.truck_id
                                controller.view.frame = self.view.bounds;
                                controller.willMove(toParentViewController: self)
                                self.ViewSubControllers.addSubview(controller.view)
                                self.addChildViewController(controller)
                                controller.didMove(toParentViewController: self)
                            }
                            
                        
                    } catch {
                    }
                    
                } else {
                    appDelegate.hideIndicator()
                }
                
            })
            
            }.resume()
        
    }
    

    
}
