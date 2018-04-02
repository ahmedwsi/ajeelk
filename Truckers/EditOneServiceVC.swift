//
//  EditOneServiceVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/11/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class EditOneServiceVC: UIViewController {

    @IBOutlet weak var ServiceNameTxt: UITextField!
    @IBOutlet weak var ServicePriceTxt: UITextField!
    
    var service_id = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServiceNameTxt.font = UIFont(name: "Arial", size:  13.0)
        ServicePriceTxt.font = UIFont(name: "Arial", size:  13.0)
        loadService()
        
    }
    
        
    @IBAction func EditServiceButton(_ sender: Any) {
        
            // if user not enter text at any field
            if ServiceNameTxt.text!.isEmpty || ServicePriceTxt.text!.isEmpty {
                
                //red placeholder
                ServiceNameTxt.attributedPlaceholder = NSAttributedString(string: "أدخل اسم الخدمة", attributes: [NSForegroundColorAttributeName : appRedColor])
                ServicePriceTxt.attributedPlaceholder = NSAttributedString(string: " أدخل سعر الخدمة", attributes: [NSForegroundColorAttributeName : appRedColor])
                
            }else{
                
                appDelegate.showIndicator()
                    let url = NSURL(string: "http://www.wsi.sa/truckers/secure/edit_service.php")!
                    var request = URLRequest(url: url as URL)
                    request.httpMethod = "POST"
                
                    let service_name = ServiceNameTxt.text!
                    let service_price = ServicePriceTxt.text!
                
                    let body = "service_id=\(service_id)&service_name=\(service_name)&service_price=\(service_price)"
                    request.httpBody = body.data(using: String.Encoding.utf8)
                    
                    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?)  in
                        if error == nil {
                            DispatchQueue.main.async {
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
                                    print("Caught an error \(error)")
                                }
                            }
                        }else{
                            print("Error \(String(describing: error))")
                        }
                    }
                        ).resume()
                }
            }

    // func of loading service from server
    func loadService() {
        
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_service_details_byid.php")!
        
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
                        
                        // getting content of $returnArray variable of php file
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        //self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new categories to store parseJSON
                        guard let service_details_array = parseJSON2["service_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        
                        self.title                  = service_details_array["service_name"] as! String
                        self.ServiceNameTxt.text    = service_details_array["service_name"] as! String
                        self.ServicePriceTxt.text    = service_details_array["service_price"] as! String
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

   

}
