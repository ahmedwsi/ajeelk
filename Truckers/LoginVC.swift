//
//  LoginVCViewController.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/25/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var usernameTxt: DesignableUITextField!
    @IBOutlet weak var passwordTxt: DesignableUITextField!

    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [ UIColor(red:0.05, green:0.69, blue:0.61, alpha:1.0).cgColor, UIColor(red:0.58, green:0.79, blue:0.25, alpha:1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = UIColor.white;

        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func SkipLoginBtn(_ sender: Any) {
        
        appDelegate.redirect()
        
    }

    
    
    @IBAction func login_click(_ sender: Any) {
        
        if Reachability.shared.isConnectedToNetwork(){
            
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty  {
            
            //red placeholder
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "بريدك الالكتروني", attributes: [NSForegroundColorAttributeName : appRedColor])
           
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "كلمة المرور", attributes: [NSForegroundColorAttributeName : appRedColor])
            
            
        }else{
            
            // Check if entered email is valid
            let providedEmailAddress = usernameTxt.text
            let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
            
            if (!isEmailAddressValid && !usernameTxt.text!.isEmpty){
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "لقد آدخلت بريد خاطئ", color: appRedColor)
                })
                                
            } else{
                appDelegate.showIndicator()
                // create new user in mysql
                let url = NSURL(string: "http://www.wsi.sa/truckers/secure/login.php")!
                var request = URLRequest(url: url as URL)
                request.httpMethod = "POST"
                let body = "username=\(usernameTxt.text!)&password=\(passwordTxt.text!)"
                request.httpBody = body.data(using: String.Encoding.utf8)
                
                URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?)  in
                    if error == nil {
                        appDelegate.showIndicator()
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
                                
                                let id = parseJSON["id"]
                                
                                if id != nil {
                                // login successfully
                                 appDelegate.hideIndicator()
                                    // save user info recieved from host
                                
                                    UserDefaults.standard.set(parseJSON , forKey:"parseJSON")
                                    user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                    //if UserDefaults.standard.string(forKey: "pic") == nil {
                                     //   user?.setValue("", forKey: "pic")
                                    //}
                                    
                                    UserDefaults.standard.synchronize()
                                    // goto home or tabbar
                                    
                                    DispatchQueue.main.async(execute: {
                                        appDelegate.login()
                                    })
                                
                                } else {
                                    appDelegate.hideIndicator()
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
            }}else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
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
