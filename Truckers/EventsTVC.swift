//
//  EventsTVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 6/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class EventsTVC: UITableViewController, UISearchBarDelegate {

    @IBOutlet var EventsTableView: UITableView!
    @IBOutlet weak var EventsSearchBar: UISearchBar!
    
    var EventsArray   = [AnyObject]()
    
    var inSearchMode = false
    
    var Events = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        EventsTableView.delegate = self
        EventsTableView.dataSource = self
        
        // Search Bar customization
        EventsSearchBar.delegate = self
        EventsSearchBar.returnKeyType = UIReturnKeyType.done
        EventsSearchBar.setValue("إلغاء", forKey: "_cancelButtonText")
        EventsSearchBar.showsCancelButton = false
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if Reachability.shared.isConnectedToNetwork(){
            
            loadEvents()
            
        }else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
        }
    }
    
    
    // func of loading events from server
    func loadEvents() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_events.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.EventsArray.removeAll(keepingCapacity: false)
                        
                        appDelegate.hideIndicator()
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare events to store parseJSON
                        guard let events = parseJSON["events"] as? [AnyObject] else {
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                            })
                            return
                        }
                        
                        self.EventsArray = events
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        appDelegate.hideIndicator()
                        
                    } catch {
                    }
                    
                } else {
                    appDelegate.hideIndicator()
                    // switch to another scene
                    //self.tabBarController?.selectedIndex = 0
                    DispatchQueue.main.async(execute: {
                        appDelegate.infoView(message: "لا توجد نتائج", color: appRedColor)
                    })
                }
                
            })
            
            }.resume()
        
    }
    
    // Search bar on change event
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // If empty searchbar
        if EventsSearchBar.text == nil || EventsSearchBar.text == "" {
            
            inSearchMode = false
            
            view.endEditing(true)
            
            loadEvents()
            
            tableView.reloadData()
            
        } else {
            
            inSearchMode = true
            
            doSearch(EventsSearchBar.text!)
            
            tableView.reloadData()
        }
    }
    
    // did begin editing of text in search bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        EventsSearchBar.showsCancelButton = true
    }
    
    
    // clicked cancel butotn of searchbar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // reset UI
        EventsSearchBar.endEditing(false) // reomove keyboard
        EventsSearchBar.showsCancelButton = false // remove cancel button
        EventsSearchBar.text = ""
        
        // clean up
        self.EventsArray.removeAll(keepingCapacity: false)
        tableView.reloadData()
        
        loadEvents()
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.EventsArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell2 = EventsTableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath as IndexPath) as! OneEventCell
        
        
        let event = self.EventsArray[indexPath.row]
        
        let event_title     = event["event_title"] as? String
        let event_location  = event["event_place"] as? String
        let event_organizer = event["event_organizer"] as? String
        let event_date      = event["event_date"] as? String
        
        let dateFormatter1 = DateFormatter()
        
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        let newdate = dateFormatter1.date(from:event_date!)

        
        //dateFormatter1.locale = Locale(identifier: "ar_SA")
        dateFormatter1.calendar = Calendar(identifier: .gregorian)
        dateFormatter1.dateFormat = "MMMM"
        
        let dateMonth       = dateFormatter1.string(from: newdate!)
        
        
        cell2.EventDayLabel.font = UIFont(name:"Arial" , size: 22.0)
        cell2.EventYearLabel.font = UIFont(name:"Arial" , size: 9.0)
        cell2.EventTitleLabel.text      = event_title
        cell2.EventLocationLabel.text   = event_location
        cell2.EventOrganizer.text       = event_organizer
        cell2.EventDayLabel.text        = event_date?.substring(from: 8)
        cell2.EventMonthLabel.text      = dateMonth
        cell2.EventYearLabel.text       = event_date?.substring(to: 4)
        
        
        return cell2
        
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
        performSegue(withIdentifier: "ShowEventDetails", sender: self)
    }
    
    
    // search / retrieve events
    func doSearch(_ word : String) {
        
        appDelegate.showIndicator()
        // shortucs
        let word = EventsSearchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let url = URL(string: "http://www.wsi.sa/truckers/secure/search_events.php")!  // url path to search_events.php file
        
        var request = URLRequest(url: url) // create request to work with search_events.php file
        
        request.httpMethod = "POST" // method of passing inf to search_events.php
        
        let body = "word=\(word)" // body that passes inf to search_events.php
        
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
                        
                        self.EventsArray.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new events to store parseJSON
                        guard let events = parseJSON["events"] as? [AnyObject] else {
                            print("Error while parseJSONing2.")
                            return
                        }
                        
                        self.EventsArray = events
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        appDelegate.hideIndicator()
                        
                        
                    } catch {
                        appDelegate.hideIndicator()
                        // get main queue to communicate back to user
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: appRedColor)
                        })
                        return
                    }
                    
                    
                } else {
                    appDelegate.hideIndicator()
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: appRedColor)
                    })
                    return
                }
                
            })
            
            } .resume()
        
        
        
    }
    
    // Segue for showing Event Details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowEventDetails") {
            
            var indexPath : IndexPath = self.tableView.indexPathForSelectedRow!
            let des_VC = segue.destination as! EventDetailsVC
            let event = self.EventsArray[indexPath.row]
            des_VC.event_id = event["event_id"] as! String
            
        }
    }
    
    
    
}

// Extension for substring
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

