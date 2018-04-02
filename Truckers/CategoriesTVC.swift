//
//  CategoriesTVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 6/8/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class CategoriesTVC: UITableViewController  {

    var pickerData   = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "العودة للتسجيل", style: .plain, target: self, action: #selector(backAction))
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func backAction(){
        let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        self.present(signUpVC, animated:true, completion:nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if Reachability.shared.isConnectedToNetwork(){
            
        loadCategories()

        }else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pickerData.count
    }

    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        performSegue(withIdentifier: "ShowTruckByCat", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath as IndexPath) as! CategoryCell
        
        let category = pickerData[indexPath.row]
        let catt_name = category["category_name_ar"] as! String
    
        
        if (category["category_icon"] is NSNull) {
            // url path to image
            cell.catPic.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
        }else{
            // url path to image
            let def_cat = category["category_icon"] as! String
            
            cell.catPic.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks_categories/\(def_cat)"))
            
        }
        cell.catNameLbl.text = catt_name
        cell.countTruckLbl.text = "عدد العربات داخل القسم :  " + (category["count_trucks"] as! String)
        
        return cell

        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowTruckByCat") {
            
            var indexPath : IndexPath = self.tableView.indexPathForSelectedRow!
            let des_VC = segue.destination as! TrucksByCatTVC
            let category = pickerData[indexPath.row]
            des_VC.trucks_by_cat = category["category_id"] as! String
        }
        
    }
    // func of loading categories from server
    func loadCategories() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_categories.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "GET"
        
        // pass information to php file
        let body2 = ""
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
                            guard let categories = parseJSON2["categories"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.pickerData = categories
                            
                            self.tableView.reloadData()
                            appDelegate.hideIndicator()
                        } else {
                            
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            self.tableView.reloadData()
                            appDelegate.hideIndicator()
                            
                        }
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            
            }.resume()
        
    }
    
    

}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}
