//
//  ShowPageVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/9/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class ShowPageVC: UIViewController {
    
    @IBOutlet weak var ContentTxt: UITextView!
    var pageId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPage(page_id: pageId)
        
    }
    
    // func of loading event from server
    func loadPage(page_id : String) {
        
        appDelegate.showIndicator()
        
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_page.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "page_id=\(page_id)"
        
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
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            
                        // declare new event details to store parseJSON
                        guard let page_details_array = parseJSON2["page_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        self.title              = page_details_array["page_title_ar"] as? String
                        

                        let page_det                   = page_details_array["page_content_ar"] as? String
                        let str = page_det?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        self.ContentTxt.text    = str
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


    
}
