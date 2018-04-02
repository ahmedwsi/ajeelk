//
//  TruckReviewsViewController.swift
//  Truckers
//
//  Created by Ahmed Elsayed on 6/18/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MobileCoreServices

class TruckReviewsViewController: UIViewController, UITextViewDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var Comments   = [AnyObject]()
    
    @IBOutlet weak var TruckRatingStars: CosmosView!
    @IBOutlet weak var ReviewComment: UITextView!
    
    @IBOutlet weak var ReviewsTableView: UITableView!
    
    @IBOutlet weak var TextCountLbl: UILabel!
    @IBOutlet weak var InsertCommentBtn: UIButton!
    @IBOutlet weak var pictureImg: UIImageView!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
    
    
    
    var uuid = String()
    var imageSelected = false
    var truck_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let parentV = self.parent as! TruckDetailsVC
        truck_id = parentV.truck_id
        
        
        
        self.ReviewsTableView.delegate = self
        self.ReviewsTableView.dataSource = self
        
        ReviewComment.delegate = self
        ReviewComment.layer.cornerRadius = ReviewComment.bounds.width / 50
        postBtn.layer.cornerRadius = postBtn.bounds.width / 30
        selectBtn.setTitleColor(appRedColor, for: .normal)
        postBtn.backgroundColor = appRedColor
        
        
        // disable auto scroll
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // disable button until text entered
        postBtn.isEnabled = false
        postBtn.alpha = 0.4

        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadReviews()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath as IndexPath) as! UserReviewCell
        
        let all_review = Comments[indexPath.row]
        let rev_username = all_review["full_name"] as! String
        
        if (all_review["pic"] is NSNull) {
            // url path to image
            cell.ReviewUserImage.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_user.png"))
        }else{
            // url path to image
            let rev_attached_photo = (all_review["pic"] as! String) 
            
            cell.ReviewUserImage.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/users/\(rev_attached_photo)"))
            
        }
        appDelegate.circularImage(photoImageView: cell.ReviewUserImage)
        
        // shortcuts
        let review_date = all_review["date_added"]!
        
        // converting date string to date
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormater.date(from: review_date! as! String)!
        
        // declare settings
        let from = newDate
        let now = Date()
        let components : NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
        
        // calculate date
        if difference.second! == 0 {
            cell.ReviewDateTimeLbl.text = "Now"
        }
        else if difference.second! > 0 && difference.minute! == 0 {
            cell.ReviewDateTimeLbl.text = "\(difference.second!) Sec." // 12s.
        }
        else if difference.minute! > 0 && difference.hour! == 0 {
            cell.ReviewDateTimeLbl.text = "\(difference.minute!) Min."
        }
        else if difference.hour! > 0 && difference.day! == 0 {
            cell.ReviewDateTimeLbl.text = "\(difference.hour!) Hours."
        }
        else if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.ReviewDateTimeLbl.text = "\(difference.day!) Days."
        }
        else if difference.weekOfMonth! > 0 {
            cell.ReviewDateTimeLbl.text = "\(difference.weekOfMonth!) Weeks."
        } else {
            cell.ReviewDateTimeLbl.text = ""
        }
        
        cell.ReviewUserNameLbl.text = rev_username
        
        cell.ReviewCommentTxt.text  = (all_review["comment"] as! String)
        cell.ReviewDateTimeLbl.font =  UIFont(name: "Arial", size: 9.0)
        
        
        if (all_review["review"] is NSNull) {
            cell.ReviewUserRating.rating = 0.0
        }else{
            let user_review    = (all_review["review"] as! NSString).doubleValue
            let roundedReview   = user_review.roundTo(places: 1)
            
            //print(truck["roundedReview"])
            cell.ReviewUserRating.rating = roundedReview
        }
        
        let att_photo = all_review["photo"] as! String 
        if (att_photo.isEmpty == true ) {
            // url path to image
            cell.ReviewAttachedImg.isHidden = true
            
        }else{
            // url path to image
    
            let rev_attached_photo2 = (all_review["photo"] as! String) 
            cell.ReviewAttachedImg.isHidden = false
            cell.ReviewAttachedImg.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks_reviews/\(rev_attached_photo2)"))

        }
        
        return cell
        
        
    }
    
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    // func of loading reviews from server
    func loadReviews() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_reviews.php")
        
        // declare request to proceed php file
        var request = URLRequest(url: url!)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "truck_id=\(truck_id)"
        request.httpBody = body.data(using: String.Encoding.utf8)
        
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.Comments.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        
                        let status = parseJSON["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let reviews = parseJSON["reviews"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.Comments = reviews
                            
                            self.ReviewsTableView.reloadData()
                            
                            appDelegate.hideIndicator()
                            
                        } else {
                            appDelegate.hideIndicator()
                            print(status)
                            // switch to another scene
                            //self.tabBarController?.selectedIndex = 0
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

    
    // entered some text in text view
    func textViewDidChange(_ textView: UITextView) {
        
        // count cahrs
        let chars = textView.text.characters.count
        
        TextCountLbl.text = String(200 - chars)
        
        if chars > 200 {
            TextCountLbl.textColor = appRedColor
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
        }else if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            postBtn.isEnabled = false
            postBtn.alpha = 0.4
        } else {
            TextCountLbl.textColor = UIColor.lightGray
            postBtn.isEnabled = true
            postBtn.alpha = 1
        }
        
    }
    
    // select picture
    @IBAction func select_click(_ sender: Any) {
        
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
        
        pictureImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // cast as a true to save image file in server
        if pictureImg.image == info[UIImagePickerControllerEditedImage] as? UIImage {
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
    func uploadComment() {
        
        // shortcuts to data to be passed to php file
        let id = user!["id"] as! String
        uuid = UUID().uuidString
        let text = ReviewComment.text.trunc(200) as String
        let review = String(TruckRatingStars.rating)
        
        // url path to php file
        let url = URL(string: "http://www.wsi.sa/truckers/secure/add_comment.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "id" : id,
            "truck_id" : truck_id,
            "review" : review,
            "text" : text
        ] as [String : Any]
        
        
        // body
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = Data()
        
        if pictureImg.image != nil {
            imageData = UIImageJPEGRepresentation(pictureImg.image!, 0.5)!
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
                            print("Error while parsing")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON3["message"]
                        
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.ReviewComment.text = ""
                            self.TextCountLbl.text = "140"
                            self.pictureImg.image = nil
                            self.postBtn.isEnabled = false
                            self.postBtn.alpha = 0.4
                            self.imageSelected = false
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
    
    
    
    @IBAction func InsertComment(_ sender: Any) {
        
        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        
        
        // if user is logged before, keep him login
        if user != nil {
            
            let id = user!["user_id"] as? String
            
            if id != nil {
                
                
                appDelegate.showIndicator()
                uploadComment()
                
            }
        
        
        }else{
    
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "عفوا , يجب تسجيل الدخول لإضافة التعليق", color: appRedColor)
            })
    
        }

    
    }

   

    
    
    
}


// Extension to stirng type of variables
extension String {
    
    // cut / trimm our string
    func trunc(_ length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
        
    }
    
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
