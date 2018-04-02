//
//  EventDetailsVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import WebKit

class EventDetailsVC: UIViewController, WKNavigationDelegate {

    var event_id = ""
    
    @IBOutlet weak var EventDateLbl: UILabel!
    @IBOutlet weak var EventOrganizerLbl: UILabel!
    @IBOutlet weak var EventPlaceLbl: UILabel!
    @IBOutlet weak var DetailsWebView: WKWebView!
    
    @IBOutlet weak var EventnameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEvent()
    }

    // func of loading event from server
    func loadEvent() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_event_details.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "event_id=\(event_id)"
        
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
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new event details to store parseJSON
                        guard let event_details_array = parseJSON2["event_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        
                        self.title                      = "الفعاليات"
                        self.EventnameLbl.text          = event_details_array["event_title"] as? String
                        self.EventDateLbl.text          = event_details_array["event_date"] as? String
                        self.EventOrganizerLbl.text     = event_details_array["event_organizer"] as? String
                        self.EventPlaceLbl.text         = event_details_array["event_place"] as? String
                        
                        let event_det                   = event_details_array["event_details"] as? String
                        //let str = event_det?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        
                        //self.wkWebView.loadHTMLString(event_det!, baseURL: nil)
                        self.DetailsWebView.loadHTMLString(event_det!, baseURL: nil)
                        appDelegate.hideIndicator()
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

}
