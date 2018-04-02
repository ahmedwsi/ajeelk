//
//  CategoriesTVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 6/8/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class TrucksByCatTVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var TrucksTabView: UITableView!
    @IBOutlet weak var TrucksSearchBar: UISearchBar!
    
    var pickerDataNew   = [AnyObject]()
    
    var inSearchMode = false
    
    var trucks_by_cat = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.TrucksSearchBar.delegate = self
        TrucksSearchBar.returnKeyType = UIReturnKeyType.done
        TrucksSearchBar.setValue("إلغاء", forKey: "_cancelButtonText")

        // search bar customization
        TrucksSearchBar.showsCancelButton = false
    
        // call func to find trucks
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if Reachability.shared.isConnectedToNetwork(){
            
            loadTrucks()
            
        }else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
        }
    }

    // func of loading trucks from server
    func loadTrucks() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_trucks.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "category_id=\(trucks_by_cat)"
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
                        
                        self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let status = parseJSON["status"] as! String
                        
                        
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let trucks = parseJSON["trucks"] as? [AnyObject] else {
                                print("Error while parseJSONing1.")
                                return
                            }
                            
                            self.pickerDataNew = trucks
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                            }
                            appDelegate.hideIndicator()
                        } else {
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            appDelegate.hideIndicator()
                        }
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                    appDelegate.hideIndicator()
                }
                
            })
            
            }.resume()
        
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if TrucksSearchBar.text == nil || TrucksSearchBar.text == "" {
            
            inSearchMode = false
            
            view.endEditing(true)
            
            loadTrucks()
            
            tableView.reloadData()
            
        } else {
            
            inSearchMode = true
            
            doSearch(TrucksSearchBar.text!)
            
            tableView.reloadData()
        }
    }
    
    // did begin editing of text in search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        TrucksSearchBar.showsCancelButton = true
    }
    
    
    // clicked cancel butotn of searchbar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // reset UI
        TrucksSearchBar.endEditing(false) // reomove keyboard
        TrucksSearchBar.showsCancelButton = false // remove cancel button
        TrucksSearchBar.text = ""
        
        // clean up
        self.pickerDataNew.removeAll(keepingCapacity: false)
        tableView.reloadData()
        
        loadTrucks()
    }

    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.pickerDataNew.count
    }

    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell2 = TrucksTabView.dequeueReusableCell(withIdentifier: "TruckTableCell", for: indexPath as IndexPath) as! CellOneTruck
        
            
        let truck = self.pickerDataNew[indexPath.row]
        
        let truck_name = truck["truck_name"] as! String
        
        if (truck["main_photo"] is NSNull) {
            // url path to image
            cell2.TruckImgView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
        }else{
            // url path to image
            let def_cat = truck["main_photo"] as! String
            
            cell2.TruckImgView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks/\(def_cat)"))
            
            
        }
        
        if (truck["truck_review"] is NSNull) {
            cell2.TruckReview.rating = 0.0
        }else{
            let truck_review    = (truck["truck_review"] as! NSString).doubleValue
            let roundedReview   = truck_review.roundTo(places: 1)
            
            //print(truck["roundedReview"])
            cell2.TruckReview.rating = roundedReview
        }
        
        appDelegate.circularImage(photoImageView: cell2.TruckImgView)
        cell2.TruckNameLbl.text = truck_name
        return cell2
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        performSegue(withIdentifier: "ShowTruckDetails", sender: self)
    }
    
    
    // search / retrieve trucks
    func doSearch(_ word : String) {
        
        appDelegate.showIndicator()
        
        // shortucs
        let word = TrucksSearchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let url = URL(string: "http://www.wsi.sa/truckers/secure/search_trucks.php")!  // url path to search_trucks.php file
        
        var request = URLRequest(url: url) // create request to work with search_trucks.php file
        
        request.httpMethod = "POST" // method of passing inf to search_trucks.php
        
        let body = "word=\(word)&category_id=\(trucks_by_cat)" // body that passes inf to search_trucks.php
        
        request.httpBody = body.data(using: .utf8) // convert str to utf8 str - supports all languages
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // getting main queue of proceeding inf to communicate back, in another way it will do it in background
            // and user will no see changes :)
            DispatchQueue.main.async(execute: {
                
                if error == nil {
                    
                    do {
                        // getting content of $returnArray variable of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new trucks to store parseJSON
                        guard let trucks = parseJSON["trucks"] as? [AnyObject] else {
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            return
                         appDelegate.hideIndicator()
                        }
                        
                        self.pickerDataNew = trucks
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        appDelegate.hideIndicator()
                        
                        
                    } catch {
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: appRedColor)
                        })
                        return
                    }
                    
                    
                } else {
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: appRedColor)
                        appDelegate.hideIndicator()
                    })
                    return
                }
                
            })
            
            } .resume()
        
        
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowTruckDetails") {
            
            var indexPath : IndexPath = self.tableView.indexPathForSelectedRow!
            let des_VC = segue.destination as! TruckDetailsVC
            let truck = self.pickerDataNew[indexPath.row]
            des_VC.truck_id = truck["truck_id"] as! String
        
        }
    }
    
    
    
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
