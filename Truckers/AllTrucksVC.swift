//
//  AllTrucksVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/7/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class AllTrucksVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

   
    
    @IBOutlet weak var TrucksTV: UITableView!
    
    var pickerDataNew   = [AnyObject]()
    
    var trucks_by_cat = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TrucksTV.dataSource = self
        self.TrucksTV.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTrucks()
        
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pickerDataNew.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TruckCell", for: indexPath) as! CellOneTruck
        
        let truck = pickerDataNew[indexPath.row]
        let truck_name = truck["truck_name"] as! String
        //let about_truck = truck["truck_details"] as! String
       
        if (truck["main_photo"] is NSNull) {
            // url path to image
            cell.TruckImgView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
        }else{
            // url path to image
            let def_cat = truck["main_photo"] as! String
            
            cell.TruckImgView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks/\(def_cat)"))
            
        }
        cell.TruckNameLbl.text = truck_name
        
        return cell
    }
    
    
    // func of loading categories from server
    func loadTrucks() {
        
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_trucks.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "POST"
        
        // pass information to php file
        let body2 = "category_id=1"
        
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
                        
                        self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new categories to store parseJSON
                        guard let trucks = parseJSON2["trucks"] as? [AnyObject] else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        self.pickerDataNew = trucks
                
                        print(trucks)
                        self.TrucksTV.reloadData()
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    
    
    
}

