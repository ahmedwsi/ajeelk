//
//  TruckServicesVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/3/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class TruckServicesVC: UIViewController , UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var ServicesTableView: UITableView!
    
    var pickerData   = [AnyObject]()
    var truck_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentV = self.parent as! TruckDetailsVC
        truck_id = parentV.truck_id
        
        
        ServicesTableView.delegate = self
        ServicesTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadServices()
        
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
        let body2 = "truck_id=\(truck_id)"
        
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
                                print("Error while parseJSONing.")
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

