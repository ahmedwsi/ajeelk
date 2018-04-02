//
//  EditProfileVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/5/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ProfileUserNameLbl: DesignableUITextField!
    @IBOutlet weak var ProfileEmailLbl: DesignableUITextField!
    @IBOutlet weak var ProfileMobileLbl: DesignableUITextField!
    @IBOutlet weak var ProfileAddressLbl: DesignableUITextField!
    @IBOutlet weak var ProfileUserImg: UIImageView!
    
    var imageSelected = false
    var uuid = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.circularImage(photoImageView:  ProfileUserImg)
        
        let profileـusername = user!["full_name"] as! String
        let profileـemail    = user!["email"] as! String
        let profileـmobile   = user!["mobile"] as! String
        let profileـaddress  = user!["address"] as! String
        let profileـpic      = user!["pic"] as! String
        
        ProfileUserNameLbl.text = profileـusername
        ProfileEmailLbl.text    = profileـemail
        ProfileMobileLbl.text   = profileـmobile
        ProfileAddressLbl.text  = profileـaddress
        
        
        
        if (profileـpic == "no_pic") {
            // url path to image
            ProfileUserImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_user.png"))
        }else{
            // url path to image
            
            ProfileUserImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/users/\(profileـpic)"))
        }
        
    }
    
    // Button onlcick to upload new profile image
    @IBAction func UploadNewProfileImgBtn(_ sender: Any) {
        
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
        
        ProfileUserImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // cast as a true to save image file in server
        if ProfileUserImg.image == info[UIImagePickerControllerEditedImage] as? UIImage {
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
    
    
    // function sending requset to PHP to uplaod a file
    func UpdateProfile() {
        
        // if user not enter text at any field
        if ProfileUserNameLbl.text!.isEmpty || ProfileEmailLbl.text!.isEmpty || ProfileMobileLbl.text!.isEmpty || ProfileAddressLbl.text!.isEmpty {
            
            //red placeholder
            ProfileUserNameLbl.attributedPlaceholder = NSAttributedString(string: "الاسم بالكامل", attributes: [NSForegroundColorAttributeName : appRedColor])
            ProfileEmailLbl.attributedPlaceholder = NSAttributedString(string: "البريد الالكتروني", attributes: [NSForegroundColorAttributeName : appRedColor])
            ProfileMobileLbl.attributedPlaceholder = NSAttributedString(string: "رقم الجوال", attributes: [NSForegroundColorAttributeName : appRedColor])
            ProfileAddressLbl.attributedPlaceholder = NSAttributedString(string: "العنوان", attributes: [NSForegroundColorAttributeName : UIColor.red])
            
        }else{
            
            // Check if entered email is valid
            let providedEmailAddress = ProfileEmailLbl.text
            let isEmailAddressValid = isValidEmailAddress(emailAddressString: providedEmailAddress!)
            
            if (!isEmailAddressValid && !ProfileEmailLbl.text!.isEmpty){
                
                DispatchQueue.main.async(execute: {
                    appDelegate.infoView(message: "لقد آدخلت بريد خاطئ", color: appRedColor)
                })
            } else {
        // shortcuts to data to be passed to php file
        let id = user!["id"] as! String
        uuid = UUID().uuidString
        
        appDelegate.showIndicator()
                
        let updatedFullName = ProfileUserNameLbl.text!
        let updatedEmail    = ProfileEmailLbl.text!
        let updatedMobile   = ProfileMobileLbl.text!
        let updatedAddress  = ProfileAddressLbl.text!
        
        // url path to php file
        let url = URL(string: "http://www.wsi.sa/truckers/secure/edit_profile.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "user_id" : id,
            "full_name" : updatedFullName,
            "mobile" : updatedMobile,
            "address" : updatedAddress,
            "email" : updatedEmail
            ] as [String : Any]
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = Data()
        
        if ProfileUserImg.image != nil {
            imageData = UIImageJPEGRepresentation(ProfileUserImg.image!, 0.5)!
        }
        
        // ... body
        request.httpBody = createBodyWithParams(param as? [String : String], filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queu to communicate back to user
            DispatchQueue.main.async(execute: {
                
                
                if error == nil {
                    
                    do {
                        
                        // json containes $returnArray from php
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        
                        // declare new var to store json inf
                        guard let parseJSON3 = json2 else {
                            print("Error while parsing 1")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON3["message"]
                        
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.imageSelected = false
                            
                            UserDefaults.standard.set(parseJSON3 , forKey:"parseJSON3")
                            user = UserDefaults.standard.value(forKey: "parseJSON3") as? NSDictionary
                            UserDefaults.standard.synchronize()
                            
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: message as! String, color: appGreenColor)
                            })
                        }
                        
                    } catch {
                        
                        // get main queue to communicate back to user
                        //print(error)
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: appRedColor)
                        })
                        return
                        
                    }
                    
                } else {
                    //print(error)
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: appRedColor)
                    })
                    return
                    
                }
                
                
            })
            
            }.resume()
            }
        }
    }
    
    
    // Form Edit Button
    @IBAction func EditBtnClick(_ sender: Any) {
        UpdateProfile()
    }


}
