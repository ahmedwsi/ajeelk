//
//  VideoSnapsVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/13/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVKit
import AVFoundation

class VideoSnapsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var Snaps   = [AnyObject]()
    
    
    @IBOutlet weak var SnapsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SnapsTableView.delegate = self
        self.SnapsTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        loadTruck()
    }
    var uuid = String()
    var imageSelected = false
    var truck_id = ""
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Snaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SnapCell", for: indexPath as IndexPath) as! OneSnapTVCTableViewCell
        
        
        let all_snaps = Snaps[indexPath.row]
        let snap_filename  = all_snaps["file_name"] as! String
        let snap_filetitle = all_snaps["file_title"] as! String
        
        
        // shortcuts
        let snap_date = all_snaps["date_added"] as? String
        
        // converting date string to date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormater.date(from: snap_date!)!
        
        // declare settings
        let from = newDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        // calculate date
        if difference.second! <= 0 {
            cell.SnapVideoDT.text = "Now"
        }
        else if difference.second! > 0 && difference.minute! == 0 {
            cell.SnapVideoDT.text = "\(difference.second!) Sec."
        }
        else if difference.minute! > 0 && difference.hour! == 0 {
            cell.SnapVideoDT.text = "\(difference.minute!) Min."
        }
        else if difference.hour! > 0 && difference.day! == 0 {
            cell.SnapVideoDT.text = "\(difference.hour!) Hours."
        }
        else if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.SnapVideoDT.text = "\(difference.day!) Days."
        }
        else if difference.weekOfMonth! > 0 {
            cell.SnapVideoDT.text = "\(difference.weekOfMonth!) Weeks."
        } else {
            cell.SnapVideoDT.text = "Unknown"
        }

        cell.SnapVideoTitle.text = snap_filetitle
        
        let videoURL = NSURL( fileURLWithPath : "http://www.wsi.sa/truckers/public/trucks_videos/\(snap_filename)")
        
        let iframe_width = cell.VideoWebview.frame.width
        let iframe_height = cell.VideoWebview.frame.height
        
        cell.VideoWebview.loadHTMLString("<iframe width = \(iframe_width) height = \(iframe_height) src= \(videoURL)></iframe>", baseURL: nil)
        cell.SnapVideoDT.font =  UIFont(name: "Arial", size: 9.0)
        
        
        return cell
        
        
    }
    
    
    
    // func of loading categories from server
    func loadTruckVideos() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_videos.php")!
        
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
                        
                        self.Snaps.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let snaps = parseJSON2["videos"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.Snaps = snaps
                            
                            DispatchQueue.main.async {
                                self.SnapsTableView.reloadData()
                            }
                            appDelegate.hideIndicator()
                            
                        } else {
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: " 1 لا توجد نتائج", color: appRedColor)
                            })
                            
                        }
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
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
                        self.loadTruckVideos()

                        
                        appDelegate.hideIndicator()
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }


    
}
