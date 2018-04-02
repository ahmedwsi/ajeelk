//
//  ChangePasswordVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/8/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {

    
    @IBOutlet weak var NewPasswordTxt: DesignableUITextField!
    @IBOutlet weak var ConfirmNewPassTxt: DesignableUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func EditPasswordButton(_ sender: Any) {
        
        
        // if user not enter text at any field
        if NewPasswordTxt.text!.isEmpty || ConfirmNewPassTxt.text!.isEmpty {
            
            //red placeholder
            NewPasswordTxt.attributedPlaceholder = NSAttributedString(string: "كلمة المرور", attributes: [NSForegroundColorAttributeName : appRedColor])
            ConfirmNewPassTxt.attributedPlaceholder = NSAttributedString(string: "تآكيد كلمة المرور", attributes: [NSForegroundColorAttributeName : appRedColor])
            
        }else{
            
                        // check if two passwords are same
            let enteredPassword     = NewPasswordTxt.text!
            let enteredConfirmPass  = ConfirmNewPassTxt.text!
            
            
            if (enteredPassword != enteredConfirmPass){
                
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "عفواً كلمتي المرور اللتان ادخلتهما غير متطابقتين", color: appRedColor)
                })
                
            } else {
                
                appDelegate.showIndicator()
                // create new user in mysql
                let url = NSURL(string: "http://www.wsi.sa/truckers/secure/change_password.php")!
                var request = URLRequest(url: url as URL)
                request.httpMethod = "POST"
                let user_id = user!["id"] as! String
                let body = "password=\(NewPasswordTxt.text!)&user_id=\(user_id)"
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
                                    
                                    // delay 4 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                                        
                                        //let prefs = UserDefaults.standard
                                        //var keyValue = prefs.string(forKey:"parseJSON")
                                        //prefs.removeObject(forKey:"parseJSON")
                                        
                                        // go to login page
                                        let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                        self.present(loginvc, animated: true, completion: nil)
                                        
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
    

}
