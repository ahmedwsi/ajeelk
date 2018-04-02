//
//  AddServiceVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/11/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class AddServiceVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var ServiceNameTxt: UITextField!
    @IBOutlet weak var ServicePriceTxt: UITextField!
    
    
    var truck_id = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTextFields()
        // Do any additional setup after loading the view.
    }

    func initializeTextFields() {
 
        ServicePriceTxt.delegate = self
        ServicePriceTxt.keyboardType = UIKeyboardType.numbersAndPunctuation
        
           }
    
    
    @IBAction func AddNewServiceBtn(_ sender: Any) {
        
        // if user not enter text at any field
        if ServiceNameTxt.text!.isEmpty || ServicePriceTxt.text!.isEmpty {
            
            //red placeholder
            ServiceNameTxt.attributedPlaceholder = NSAttributedString(string: "أدخل اسم الخدمة", attributes: [NSForegroundColorAttributeName : appRedColor])
            ServicePriceTxt.attributedPlaceholder = NSAttributedString(string: " أدخل سعر الخدمة", attributes: [NSForegroundColorAttributeName : appRedColor])
            
        }else{
            
            appDelegate.showIndicator()
            let url = NSURL(string: "http://www.wsi.sa/truckers/secure/add_service.php")!
            var request = URLRequest(url: url as URL)
            request.httpMethod = "POST"
            
            let service_name = ServiceNameTxt.text!
            let service_price = ServicePriceTxt.text!
            
            
            let body = "truck_id=\(truck_id)&service_name=\(service_name)&service_price=\(service_price)"
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
    

}
