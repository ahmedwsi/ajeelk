//
//  ViewController.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 5/21/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate {
    
    

    @IBOutlet weak var usernameTxt: DesignableUITextField!
    @IBOutlet weak var emailTxt: DesignableUITextField!
    @IBOutlet weak var passwordTxt: DesignableUITextField!
    @IBOutlet weak var confirmPasswordTxt: DesignableUITextField!
    @IBOutlet weak var mobileTxt: DesignableUITextField!
    @IBOutlet weak var addressTxt: DesignableUITextField!
    @IBOutlet weak var countryTxt: DesignableUITextField!
    
    @IBOutlet weak var PickCountries: UIPickerView!
    
    @IBOutlet weak var regBtn: UIButton!
    var countryData = [AnyObject]()
    var countryData2 = [AnyObject]()
    var countryData3 = [AnyObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [ UIColor(red:0.05, green:0.69, blue:0.61, alpha:1.0).cgColor, UIColor(red:0.58, green:0.79, blue:0.25, alpha:1.0).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradient, at: 0)
        self.hideKeyboardWhenTappedAround()
        
        loadCountries()
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tap2.cancelsTouchesInView = false
        view.addGestureRecognizer(tap2)
        
        self.PickCountries.dataSource   = self
        self.PickCountries.delegate     = self
        regBtn.layer.cornerRadius = regBtn.bounds.width / 15
        self.countryTxt.delegate = self
        
        //self.automaticallyAdjustsScrollViewInsets = false
        
    }

    
    // func of loading posts from server
    func loadCountries() {
        
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_countries.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "GET"
        
        // pass information to php file
        let body2 = ""
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
                        
                        self.countryData.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new categories to store parseJSON
                        guard let countries = parseJSON2["countries"] as? [AnyObject] else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        self.countryData = countries
                        
                        for i in 0 ..< self.countryData.count {
                            
                            let country_name = self.countryData[i]["Name"] as? String
                            let country_code = self.countryData[i]["phoneCode"] as? String
                            
                            self.countryData2.append(country_name as AnyObject)
                            self.countryData3.append(country_code as AnyObject)
                        }
                        
                        // append all posts var's inf to categories
                        
                        // print(self.pickerData2)
                        
                        // reload tableView to show back information
                        self.PickCountries.reloadAllComponents()
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    
    // touched screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    // returns the number of 'columns' to display.
    func numberOfComponents( in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView == PickCountries {
            return countryData2.count
        } 
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView == PickCountries {
            self.view.endEditing(true)
            return (countryData2[row] as! String)
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont(name: "GE SS Two", size: 12)
        pickerLabel.textAlignment = .center
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.minimumScaleFactor = 0.5
        
        if pickerView == PickCountries {
            
            pickerLabel.text = countryData2[row] as? String
            
        }
        return pickerLabel
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == PickCountries {
            self.countryTxt.text = self.countryData2[row] as? String
            self.mobileTxt.text = self.countryData3[row] as? String
            
            //self.PickCountries.isHidden = true
            self.view.endEditing(true)
        }
    }
    
    
    // register button clicked
    @IBAction func register_click(_ sender: Any) {
        
                // if user not enter text at any field
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || confirmPasswordTxt.text!.isEmpty || emailTxt.text!.isEmpty || mobileTxt.text!.isEmpty || addressTxt.text!.isEmpty {
            
            //red placeholder
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "الاسم بالكامل", attributes: [NSForegroundColorAttributeName : appRedColor])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "البريد الالكتروني", attributes: [NSForegroundColorAttributeName : appRedColor])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "كلمة المرور", attributes: [NSForegroundColorAttributeName : appRedColor])
            confirmPasswordTxt.attributedPlaceholder = NSAttributedString(string: "تآكيد كلمة المرور", attributes: [NSForegroundColorAttributeName : appRedColor])
            mobileTxt.attributedPlaceholder = NSAttributedString(string: "ex 9665xxxxxxxx", attributes: [NSForegroundColorAttributeName : appRedColor])
            addressTxt.attributedPlaceholder = NSAttributedString(string: "العنوان", attributes: [NSForegroundColorAttributeName : appRedColor])
            
        }else{
            
            // Check if entered email is valid
            let providedEmailAddress = emailTxt.text
            let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
            
            // check if two passwords are same
            let enteredPassword     = passwordTxt.text!
            let enteredConfirmPass  = confirmPasswordTxt.text!

            
            if (!isEmailAddressValid && !emailTxt.text!.isEmpty){
                
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "لقد آدخلت بريد خاطئ", color: appRedColor)
                })
            } else if (enteredPassword != enteredConfirmPass){
                
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "عفواً كلمتي المرور اللتان ادخلتهما غير متطابقتين", color: appRedColor)
                })
                                
            } else {
                
            // create new user in mysql
                appDelegate.showIndicator()
                
            let url = NSURL(string: "http://www.wsi.sa/truckers/secure/register.php")!
            var request = URLRequest(url: url as URL)
            request.httpMethod = "POST"
            let body = "username=\(usernameTxt.text!)&password=\(passwordTxt.text!)&email=\(emailTxt.text!.lowercased())&mobile=\(mobileTxt.text!)&address=\(addressTxt.text!)"
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
                                    
                                    // go to login page
                                    let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    self.present(loginvc, animated: true, completion: nil)
                                
                                })
                                // save user info recieved from host
                                //UserDefaults.standard.set(parseJSON , forKey:"parseJSON")
                                //user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
                                
                                // goto home or tabbar
                                
                                //DispatchQueue.main.async(execute: {
                                    //appDelegate.login()
                                //})

                                
                            } else {
                                
                                DispatchQueue.main.async(execute: {
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: appRedColor)
                                })
                                appDelegate.hideIndicator()
                            }
                        } catch {
                            print("Caught an error \(error)")
                            appDelegate.hideIndicator()
                        }
                    }
                }else{
                    print("Error \(String(describing: error))")
                    appDelegate.hideIndicator()
                }
            }
                ).resume()
            }
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // touched screen
   
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.countryTxt {
            self.PickCountries.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(PickCountries, didSelectRow: 0, inComponent: 0)
            self.PickCountries.isHidden = false
         
            self.view.endEditing(true)
            
        }
       
    }
    
    
    func handleTapGesture(sender: AnyObject)
    {
        self.PickCountries.isHidden = true
        self.view.endEditing(true)
    }
    
}

// Creating protocol of appending string to var of type data

