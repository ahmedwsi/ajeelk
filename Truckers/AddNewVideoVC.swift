//
//  AddNewVideoVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/15/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MobileCoreServices
import AssetsLibrary


class AddNewVideoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var VideoTitleTxt: UITextField!
    
    @IBOutlet weak var AddBtn: UIButton!
    @IBOutlet weak var ChooseVideo: UIButton!
    
    @IBOutlet weak var AddWebView: UIWebView!
    
    var vid_url = NSURL()
    var newMedia = false
    var imagePicker = UIImagePickerController()
    var urlOfVideo = NSURL()
    var copypath = String()
    var videoPath = String()
    var uuid = UUID().uuidString
    var truck_id = ""
    var filename = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
  
    override func viewDidAppear(_ animated: Bool) {
        loadTruck()
    }
    
    @IBAction func RecordVideoBtn(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            
            
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.allowsEditing = false
            imagePicker.videoMaximumDuration = 7
            
            imagePicker.showsCameraControls = true
            
            self.present(imagePicker, animated: true, completion: nil)
            newMedia = true
        } else {
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "الكاميرا غير متاحة", color: appRedColor)
            })
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeMovie as String)
        {
            //vid_url = info[UIImagePickerControllerMediaURL] as! NSURL
            
        }
        vid_url = info[UIImagePickerControllerMediaURL] as! NSURL
        filename = vid_url.pathComponents!.last!
        newMedia = true

        
        let iframe_width = self.AddWebView.frame.width
        let iframe_height = self.AddWebView.frame.height
        
        
        
        self.dismiss(animated: true, completion: nil)
        self.AddWebView.loadHTMLString("<iframe width = \(iframe_width) height = \(iframe_height) src= \(vid_url)></iframe>", baseURL: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
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
        
        let mimetype = "video/mov"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
        
    }

    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
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
    
    func uploadVideoFile(){
        
        //let imagePAth = URL(fileURLWithPath:(self.getDirectoryPath() as NSString).appendingPathComponent("movie.mov") )
        appDelegate.showIndicator()
        //print(imagePAth)
        guard let videoPathString = self.vid_url.path else {
            //handle error here if you can't create a path string
            return
        }
        
        var movieData: NSData?
        do {
            movieData = try NSData(contentsOfFile: (videoPathString), options: NSData.ReadingOptions.alwaysMapped)
        } catch _ {
            movieData = nil
            return
        }
        
        let url = URL(string: "http://www.wsi.sa/truckers/secure/add_video.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let video_title = VideoTitleTxt.text!
        // param to be passed to php file
        let param = [
            "truck_id" : truck_id,
            "video_title" : video_title
            ] as [String : Any]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        // ... body
        request.httpBody = createBodyWithParams(param as? [String : String], filePathKey: "file", imageDataKey: movieData! as Data, boundary: boundary)
                // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queu to communicate back to user
            DispatchQueue.main.async(execute: {
                
                
                if error == nil {
                    
                    print("run button3")
                    
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
                            self.newMedia = false
                            appDelegate.hideIndicator()
                            
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
                            DispatchQueue.main.async(execute: {
                                appDelegate.infoView(message: message as! String, color: appGreenColor)
                            })
                            // delay 4 seconds
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
    
    
    @IBAction func AddViedeoBtnn(_ sender: Any) {
        // if user not enter text at any field
        if VideoTitleTxt.text!.isEmpty  {
            VideoTitleTxt.attributedPlaceholder = NSAttributedString(string: "أدخل عنوان الفيديو", attributes: [NSForegroundColorAttributeName : appRedColor])
        
        }else if vid_url.absoluteString == "" {
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "عفوا لم تقم بارفاق الفيديو ، قم بالضغط على زر : سجل مباشرة من الكاميرا", color: appRedColor)
            })

        }else{
            uploadVideoFile()
        }
    }
    
    

}


