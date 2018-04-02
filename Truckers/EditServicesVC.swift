//
//  TruckServicesVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/3/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class EditServicesVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var ServicesTableView: UITableView!
    
    var pickerData   = [AnyObject]()
    var truck_id = ""
    
    let cellReuseIdentifier = "ServiceCell"

    
    //@IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
    }
 
    override func viewDidAppear(_ animated: Bool) {
        loadTruck()
        
        ServicesTableView.delegate = self
        ServicesTableView.dataSource = self
        //ServicesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //performSegue(withIdentifier: "EditService", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            var indexPath : IndexPath = self.ServicesTableView.indexPathForSelectedRow!
            let service = self.pickerData[indexPath.row]
            let service_id = service["service_id"] as! String
            delete_service(service_id: service_id)

            ServicesTableView.reloadData()
        }
    }
    
    @IBAction func AddServiceBtnTop(_ sender: Any) {
       // performSegue(withIdentifier: "AddService", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditService") {
            
            var indexPath : IndexPath = self.ServicesTableView.indexPathForSelectedRow!
            let des_VC = segue.destination as! EditOneServiceVC
            let service = self.pickerData[indexPath.row]
            des_VC.service_id = service["service_id"] as! String
            
        } else if (segue.identifier == "AddService") {
            
            let des_VC = segue.destination as! AddServiceVC
            des_VC.truck_id = truck_id
            
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pickerData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath as IndexPath) as! ServiceCellVC
        
        let service = pickerData[indexPath.row]
        let service_name = service["service_name"] as! String
        
        cell.ServiceNameLabl.text = service_name
        cell.ServicePriceLbl.text = (service["service_price"] as! String)
        
        cell.ServiceIdLbl.text    = "\(indexPath.row + 1)"
        
        
        return cell
        
        
    }
    
    
    // func of loading truck from server
    func loadTruck() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_details_byid.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        let user_id = user!["id"] as! String
        
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
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        //self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let truck_details_array = parseJSON2["truck_all_details"] as? AnyObject else {
                                print("Error while parseJSONing.T")
                                return
                            }
                            
                            
                            self.truck_id               = truck_details_array["truck_id"] as! String
                            self.loadServices()
                            appDelegate.hideIndicator()
                            
                        } else {
                            appDelegate.hideIndicator()
                            // switch to another scene
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            
                        }
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

    // func of loading truck from server
    func delete_service(service_id:String) {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/delete_service.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "service_id=\(service_id)"
        
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        guard let parseJSON = json
                            else {
                                
                                DispatchQueue.main.async(execute: {
                                    appDelegate.infoView(message: "عفواً توجد مشكلة بالادخال", color: appRedColor)
                                })
                                
                                return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON["message"] as! String
                        
                        
                        // if there is some message - post is made
                        if message != nil {
                            appDelegate.hideIndicator()
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: message, color: appGreenColor)
                            })
                            
                            // delay 4 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                                
                                
                                // go to back page
                                _ = self.navigationController?.popViewController(animated: true)
                                
                                
                            })
                            
                            
                        } else {
                            
                            DispatchQueue.main.async(execute: {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: appRedColor)
                            })
                            
                        }
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

    
    // func of loading services from server
    func loadServices() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_services.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "POST"
        
        // pass information to php file
        // pass information to php file
        let body2 = "truck_id=\(self.truck_id)"
       
        request2.httpBody = body2.data(using: String.Encoding.utf8)
        
        // launch session
        URLSession.shared.dataTask(with: request2) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.pickerData.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                            
                        }
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let services = parseJSON2["services"] as? [AnyObject] else {
                                print("Error while parseJSONing.S")
                                return
                            }
                            
                            self.pickerData = services
                            
                            self.ServicesTableView.reloadData()
                            appDelegate.hideIndicator()
                            
                        } else {
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            
                        }
                        
                       
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    
    
}

