//
//  NewTruckVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/1/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class NewTruckVC: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var truckName: UITextField!
    
    @IBOutlet weak var TruckImgView: UIImageView!
    @IBOutlet weak var aboutTruck: UITextView!
    @IBOutlet weak var truckMobile: UITextField!
    @IBOutlet weak var truckEmail: UITextField!
    @IBOutlet weak var addTruckBtn: UIButton!
    
    @IBOutlet weak var truck_type: UIPickerView!
    
    @IBOutlet weak var workTeam: UIPickerView!
    @IBOutlet weak var workTeamTxt: UITextField!
    
    @IBOutlet weak var truck_typeTxt: UITextField!
    
    @IBOutlet weak var CatNameTxt: UITextField!
    @IBOutlet weak var SelectService: UIPickerView!
    
    var imageSelected = false
    var uuid = String()
    
    var pickerData = [AnyObject]()
    var pickerData2 = [AnyObject]()

    var Types = ["عربة ثابتة","عربة متحركة"]
    var WorkTeams = ["رجال","نساء"]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.automaticallyAdjustsScrollViewInsets = false
        loadCategories()
        addTruckBtn.backgroundColor = appRedColor
        appDelegate.circularImage(photoImageView:  TruckImgView)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tap2.cancelsTouchesInView = false
        view.addGestureRecognizer(tap2)
        
        self.SelectService.dataSource   = self
        self.SelectService.delegate     = self
        self.truck_type.dataSource      = self
        self.truck_type.delegate        = self
        self.workTeam.dataSource        = self
        self.workTeam.delegate          = self
        
        self.CatNameTxt.delegate        = self
        self.truck_typeTxt.delegate     = self
        self.workTeamTxt.delegate       = self
        
    }
    
    // pre load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // call func of laoding posts
       
    }
    
    
    @IBAction func SelectTruckImg(_ sender: Any) {
        
        let camera = DSCameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "الكاميرا", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "مكتبة الصور", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "إلغاء", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    
    // selected image in picker view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        TruckImgView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // cast as a true to save image file in server
        if TruckImgView.image == info[UIImagePickerControllerEditedImage] as? UIImage {
            imageSelected = true
        }
    }
    
    // touched screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    
    // custom body of HTTP request to upload image file
    func createBodyWithParams(_ parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        
        // if file is not selected, it will not upload a file to server, because we did not declare a name file
        var filename = ""
        
        if imageSelected == true {
            filename = "profile-1111.jpg"
        }
        
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }
    
    
    
    @IBAction func AddBtn_Click(_ sender: Any) {
        
        if truckName.text!.isEmpty || truckEmail.text!.isEmpty || truckMobile.text!.isEmpty || truck_typeTxt.text!.isEmpty || workTeamTxt.text!.isEmpty || CatNameTxt.text!.isEmpty {
            
            //red placeholder
            truckName.attributedPlaceholder = NSAttributedString(string: "ادخل اسم العربة ", attributes: [NSForegroundColorAttributeName : appRedColor])
            truckEmail.attributedPlaceholder = NSAttributedString(string: "ادخل البريد الإلكتروني للعربة", attributes: [NSForegroundColorAttributeName : appRedColor])
            truckMobile.attributedPlaceholder = NSAttributedString(string: "أدخل رقم جوال العربة", attributes: [NSForegroundColorAttributeName : appRedColor])
            truck_typeTxt.attributedPlaceholder = NSAttributedString(string: "اختر حالة العربة", attributes: [NSForegroundColorAttributeName : appRedColor])
            workTeamTxt.attributedPlaceholder = NSAttributedString(string: "اختر نوع فريق العمل", attributes: [NSForegroundColorAttributeName : appRedColor])
            CatNameTxt.attributedPlaceholder = NSAttributedString(string: "اختر القسم", attributes: [NSForegroundColorAttributeName : appRedColor])
            
        }else{
            
            let providedEmailAddress = truckEmail.text
            let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
            
            if (!isEmailAddressValid && !truckEmail.text!.isEmpty){
                
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "لقد آدخلت بريد خاطئ", color: appRedColor)
                })
            } else {
                
                appDelegate.showIndicator()
                // create new user in mysql
                
                uuid = UUID().uuidString
                
                let url = URL(string: "http://www.wsi.sa/truckers/secure/new_truck.php")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let user_id         = user!["user_id"] as! String
                let truck_name      = truckName.text!
                let truck_email     = truckEmail.text!
                let truck_mobile    = truckMobile.text!
                let about_truck     = aboutTruck.text!
                let truck_category  = CatNameTxt.text!
                let truck_type      = truck_typeTxt.text!
                let work_team       = workTeamTxt.text!
                
                
                let param = [
                    "user_id" : user_id,
                    "truck_name" : truck_name,
                    "truck_mobile" : truck_mobile,
                    "truck_email" : truck_email,
                    "truck_category" : truck_category,
                    "truck_type" : truck_type,
                    "work_team" : work_team,
                    "truck_details" : about_truck
                    
                    ] as [String : Any]
                
                // body
                let boundary = "Boundary-\(UUID().uuidString)"
                
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                // if picture is selected, compress it by half
                var imageData = Data()
                
                if TruckImgView.image != nil {
                    imageData = UIImageJPEGRepresentation(TruckImgView.image!, 0.5)!
                }
                
                // ... body
                request.httpBody = createBodyWithParams(param as? [String : String], filePathKey: "file", imageDataKey: imageData, boundary: boundary)
                
                 
                URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?)  in
                    if error == nil {
                        //DispatchQueue.main.async {
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
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                                        
                                        // go to home page
                                        appDelegate.redirect()
                                        
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
                       // }
                    }else{
                        print("Error \(String(describing: error))")
                    }
                }
                    ).resume()
            }
        }
    }
    
    
    // func of loading posts from server
    func loadCategories() {
        
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_categories.php")!
        
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
                        
                        self.pickerData.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new categories to store parseJSON
                        guard let categories = parseJSON2["categories"] as? [AnyObject] else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        self.pickerData = categories

                        for i in 0 ..< self.pickerData.count {
                            
                            let cat_name = self.pickerData[i]["category_name_ar"] as? String
                            
                            self.pickerData2.append(cat_name as AnyObject)

                        }
                        
                        // append all posts var's inf to categories
                        
                        // print(self.pickerData2)
                        
                        // reload tableView to show back information
                        self.SelectService.reloadAllComponents()
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    

    // returns the number of 'columns' to display.
    func numberOfComponents( in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView == SelectService {
            return pickerData2.count
        } else if pickerView == truck_type {
            return Types.count
        } else if pickerView == workTeam {
            return WorkTeams.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if pickerView == SelectService {
            self.view.endEditing(true)
            return (pickerData2[row] as! String)
        } else if pickerView == truck_type {
            self.view.endEditing(true)
            return (Types[row])
        } else if pickerView == workTeam {
            self.view.endEditing(true)
            return (WorkTeams[row])
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont(name: "GE SS Two", size: 12)
        pickerLabel.textAlignment = .center
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.minimumScaleFactor = 0.5
        
        if pickerView == SelectService {
            
            pickerLabel.text = pickerData2[row] as? String
            
            
        } else if pickerView == truck_type {
            pickerLabel.text = Types[row]

            
        } else if pickerView == workTeam {
            pickerLabel.text = WorkTeams[row]

            
        }
        return pickerLabel
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == SelectService {
            self.CatNameTxt.text = self.pickerData2[row] as? String
            self.SelectService.isHidden = true
            self.view.endEditing(true)
        
        } else if pickerView == truck_type {
            self.truck_typeTxt.text = self.Types[row]
            self.truck_type.isHidden = true
            self.view.endEditing(true)
            
        } else if pickerView == workTeam {
            self.workTeamTxt.text = self.WorkTeams[row]
            self.workTeam.isHidden = true
            self.view.endEditing(true)
        }
                
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.CatNameTxt {
            self.SelectService.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(SelectService, didSelectRow: 0, inComponent: 0)
            self.SelectService.isHidden = false
            self.truck_type.isHidden = true
            self.workTeam.isHidden = true
            self.view.endEditing(true)

        }
        else if textField == self.truck_typeTxt {
            self.truck_type.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(truck_type, didSelectRow: 0, inComponent: 0)
            self.SelectService.isHidden = true
            self.truck_type.isHidden = false
            self.workTeam.isHidden = true
            self.view.endEditing(true)
            
        } else if textField == self.workTeamTxt {
            self.workTeam.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(workTeam, didSelectRow: 0, inComponent: 0)
            self.SelectService.isHidden = true
            self.truck_type.isHidden = true
            self.workTeam.isHidden = false
            self.view.endEditing(true)
        }
    }
    

    func handleTapGesture(sender: AnyObject)
    {
            self.SelectService.isHidden = true
            self.truck_type.isHidden = true
            self.workTeam.isHidden = true
            self.view.endEditing(true)
    }
    
}




// Creating protocol of appending string to var of type data
extension NSMutableData {
    
    func appendString(_ string : String) {
        
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
        
    }
    
}


