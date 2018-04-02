//
//  AddNewPhotoVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/17/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MobileCoreServices


class AddNewPhotoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var uuid = String()
    var imageSelected = false
    var truck_id = ""
    
    @IBOutlet weak var PhototitleTxt: UITextField!
    @IBOutlet weak var PhotoImageView: UIImageView!
    @IBOutlet weak var PostBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTruck()
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func SelectPhotoBtn(_ sender: Any) {
        
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
        
        PhotoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // cast as a true to save image file in server
        if PhotoImageView.image == info[UIImagePickerControllerEditedImage] as? UIImage {
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
            filename = "review-1111.jpg"
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
    func uploadPhoto() {
        
        appDelegate.showIndicator()
        
        // shortcuts to data to be passed to php file

        uuid = UUID().uuidString
        let photo_title = PhototitleTxt.text!
        
        // url path to php file
        let url = URL(string: "http://www.wsi.sa/truckers/secure/add_photo.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "truck_id" : truck_id,
            "photo_title" : photo_title
            ] as [String : Any]
        
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = Data()
        
        if PhotoImageView.image != nil {
            imageData = UIImageJPEGRepresentation(PhotoImageView.image!, 0.5)!
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
                            print("Error while parsing1")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON3["message"]
                        
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.PhototitleTxt.text = ""
                            self.PhotoImageView.image = nil
                            self.PostBtn.isEnabled = false
                            self.PostBtn.alpha = 0.4
                            self.imageSelected = false
                            appDelegate.hideIndicator()
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: message as! String, color: appGreenColor)
                            })
                            // delay 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                                
                                // go to back page
                                _ = self.navigationController?.popViewController(animated: true)
                                
                                
                            })
                        }
                        
                    } catch {
                        
                        // get main queue to communicate back to user
                        //print(error)
                        DispatchQueue.main.async(execute: {
                            let message = "\(error)"
                            appDelegate.infoView(message: message, color: appRedColor)
                        })
                        appDelegate.hideIndicator()
                        return
                        
                    }
                    
                } else {
                    //print(error)
                    // get main queue to communicate back to user
                    DispatchQueue.main.async(execute: {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: appRedColor)
                    })
                    appDelegate.hideIndicator()
                    return
                    
                }
                
                
            })
            
            }.resume()
        
    }

    @IBAction func AddPhotoBtn(_ sender: Any) {
        
        // if user not enter text at any field
        if PhototitleTxt.text!.isEmpty  {
            PhototitleTxt.attributedPlaceholder = NSAttributedString(string: "أدخل عنوان الصورة", attributes: [NSForegroundColorAttributeName : appRedColor])
            
        }else if imageSelected == false {
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "عفوا لم تقم بارفاق الصورة ", color: appRedColor)
            })
            
        }else{
            uploadPhoto()
        }

        
        
    }
    // func of loading truck from server
    func loadTruck() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_details_byid.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        let user_id = user!["id"] as! String
        
        // pass information to php file
        let body = "user_id=\(user_id)"
        
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
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let truck_details_array = parseJSON2["truck_all_details"] as? AnyObject else {
                                print("Error while parseJSONing.T")
                                return
                            }
                            
                            
                            self.truck_id               = truck_details_array["truck_id"] as! String
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
