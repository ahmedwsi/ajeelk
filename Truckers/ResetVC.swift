//
//  ResetVC.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/27/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class ResetVC: UIViewController {

    
    @IBOutlet weak var emailTxt: DesignableUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [ UIColor(red:0.05, green:0.69, blue:0.61, alpha:1.0).cgColor, UIColor(red:0.58, green:0.79, blue:0.25, alpha:1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradient, at: 0)
        // Do any additional setup after loading the view.
    }


    @IBAction func reset_click(_ sender: Any) {
        
        // if no text entered
        if emailTxt.text!.isEmpty  {
            
            //red placeholder
            emailTxt.attributedPlaceholder = NSAttributedString(string: "ادخل بريدك الالكتروني", attributes: [NSForegroundColorAttributeName : appRedColor])
            
            
        // if texet entered
        } else {
            
            appDelegate.showIndicator()
            // create new user in mysql
            let email = emailTxt.text!.lowercased()
            
            let url = NSURL(string: "http://www.wsi.sa/truckers/secure/resetPassword.php")!
            var request = URLRequest(url: url as URL)
            request.httpMethod = "POST"
            let body = "email=\(email)"
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
                            
                            let id = parseJSON["user_id"]
                            
                            if id != nil {
                                
                                appDelegate.hideIndicator()
                                
                                let message = parseJSON["message"] as! String
                                
                                DispatchQueue.main.async(execute: {
                                    appDelegate.infoView(message: message, color: appGreenColor)
                                })
                                
                            }else {
                                
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // touched screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    
}
