//
//  TruckGalleryVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/17/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class TruckGalleryVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var ImagesTableView: UITableView!
    var truck_id = ""
    var images   = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        ImagesTableView.delegate = self
        ImagesTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        loadTruck()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath as IndexPath) as! OnePhotoTVC
        
        
        let all_images = images[indexPath.row]
        let image_filetitle = all_images["file_title"] as! String
        
        
        // shortcuts
        let image_date = all_images["date_added"] as? String
        
        // converting date string to date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormater.date(from: image_date!)!
        
        // declare settings
        let from = newDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        // calculate date
        if difference.second! <= 0 {
            cell.PhotoDateTimeTxt.text = "Now"
        }
        if difference.second! > 0 && difference.minute! == 0 {
            cell.PhotoDateTimeTxt.text = "\(difference.second!) Sec."
        }
        if difference.minute! > 0 && difference.hour! == 0 {
            cell.PhotoDateTimeTxt.text = "\(difference.minute!) Min."
        }
        if difference.hour! > 0 && difference.day! == 0 {
            cell.PhotoDateTimeTxt.text = "\(difference.hour!) Hours."
        }
        if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.PhotoDateTimeTxt.text = "\(difference.day!) Days."
        }
        if difference.weekOfMonth! > 0 {
            cell.PhotoDateTimeTxt.text = "\(difference.weekOfMonth!) Weeks."
        }
        
        cell.photoTitleTxt.text = image_filetitle
                let truck_image = self.images[indexPath.row]
        
        if (truck_image["file_name"] is NSNull) {
            // url path to image
            cell.ImageV.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
        }else{
            // url path to image
            let def_cat = truck_image["file_name"] as! String
            //print(def_cat)
            cell.ImageV.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks_files/\(def_cat)"))
        }
        
        

        return cell
        
        
    }
    
    
    // func of loading trucks from server
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
                        
                        // declare new categories to store parseJSON
                        guard let truck_details_array = parseJSON2["truck_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        
                        self.truck_id               = truck_details_array["truck_id"] as! String
                        self.loadTruckGallery()
                        
                        
                        appDelegate.hideIndicator()
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

    
    // func of loading categories from server
    func loadTruckGallery() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_gallery.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "POST"
        
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
                        
                        self.images.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let categories = parseJSON2["images"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.images = categories
                            
                            DispatchQueue.main.async {
                                self.ImagesTableView.reloadData()
                            }
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


   

