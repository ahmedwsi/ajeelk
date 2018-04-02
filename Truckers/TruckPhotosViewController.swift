//
//  TruckPhotosViewController.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/18/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class TruckPhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var CollectionView: UICollectionView!
    var images = [AnyObject]() as Array
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var truck_id = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let parentV = self.parent as! TruckDetailsVC
        
        truck_id = parentV.truck_id
        
        loadTruckGallery()

        
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        CollectionView.collectionViewLayout = layout
        

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! CustomCell
        cell.layer.cornerRadius = 3
        cell.layer.borderColor = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.9).cgColor
        cell.layer.borderWidth = 1
        
        cell.MyImage.contentMode = .scaleAspectFill
        

        let truck_image = self.images[indexPath.row]
        
        if (truck_image["file_name"] is NSNull) {
            // url path to image
            cell.MyImage.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
        }else{
            // url path to image
            let def_cat = truck_image["file_name"] as! String
            //print(def_cat)
            cell.MyImage.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks_files/\(def_cat)"))
        }
        
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(TruckPhotosViewController.imageTapped))
        cell.MyImage.addGestureRecognizer(pictureTap)
        cell.MyImage.isUserInteractionEnabled = true
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 0
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
    
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        imageView.fadeIn()
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        
        
        newImageView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        //self.view.addSubview(newImageView)
        
        let parentVC = self.parent as! TruckDetailsVC
        
        parentVC.view.addSubview(newImageView)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        sender.view?.removeFromSuperview()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    // func of loading categories from server
    func loadTruckGallery() {
        
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_gallery.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "POST"
        
        // pass information to php file
        let body2 = "truck_id=\(truck_id)"
        
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
                        
                        self.images.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let categories = parseJSON2["images"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.images = categories
                            
                            DispatchQueue.main.async {
                                self.CollectionView.reloadData()
                            }
                            appDelegate.hideIndicator()
                            
                        } else {
                            appDelegate.hideIndicator()
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


}


extension UIView {
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
}
