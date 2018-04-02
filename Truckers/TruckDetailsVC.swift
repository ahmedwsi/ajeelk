//
//  TruckDetailsVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/17/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit


class TruckDetailsVC: UIViewController {
    
    enum TabIndex : Int {
        case firstChildTab = 0
        case secondChildTab = 1
        case thirdChildTab = 2
        case fourthChildTab = 3
        case fifthChildTab = 4
    }
    
  
    
    
    
    @IBOutlet weak var TruckImageView: UIImageView!
    @IBOutlet weak var TabBarSegCtrl: UISegmentedControl!
    @IBOutlet weak var ContentView: UIScrollView!
    
    
    var currentViewController: UIViewController?
    lazy var firstChildTabVC: UIViewController? = {
        let firstChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "AboutTruckVC")
        return firstChildTabVC
    }()
    lazy var secondChildTabVC : UIViewController? = {
        let secondChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "TruckPhotosVC")
        
        return secondChildTabVC
    }()
    lazy var thirdChildTabVC : UIViewController? = {
        let thirdChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "TruckReviewsVC")
        
        return thirdChildTabVC
    }()
    lazy var fourthChildTabVC : UIViewController? = {
        let fourthChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "TruckServicesVC")
        
        return fourthChildTabVC
    }()
    lazy var fifthChildTabVC : UIViewController? = {
        let fifthChildTabVC = self.storyboard?.instantiateViewController(withIdentifier: "TruckVideos")
        
        return fifthChildTabVC
    }()
    
    func viewControllerForSelectedSegmentIndex(_ index: Int) -> UIViewController? {
        var vc: UIViewController?
        switch index {
        case TabIndex.firstChildTab.rawValue :
            vc = firstChildTabVC
                        
        case TabIndex.secondChildTab.rawValue :
            vc = secondChildTabVC
            
        case TabIndex.thirdChildTab.rawValue :
            vc = thirdChildTabVC
            
        case TabIndex.fourthChildTab.rawValue :
            vc = fourthChildTabVC
            
        case TabIndex.fifthChildTab.rawValue :
            vc = fifthChildTabVC
            
        default:
            return nil
        }
        
        return vc
    }
    
    
    var TruckImage = ""
    var truck_id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTruck()
        
        ContentView.contentSize = CGSize(width: self.view.frame.size.width, height:  self.view.frame.size.height)

        TabBarSegCtrl.selectedSegmentIndex = TabIndex.firstChildTab.rawValue
        displayCurrentTab(TabIndex.firstChildTab.rawValue)
        
        
        //TruckNameLabel.text = truck_details["truck_name"]
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "AboutTruckVID") {
            let des_VC = segue.destination as! AboutTruckViewController

            des_VC.truck_id1 = truck_id
        }
        
    }
    
    func displayCurrentTab(_ tabIndex: Int){
        if let vc = viewControllerForSelectedSegmentIndex(tabIndex) {
            
            self.addChildViewController(vc)
            
            vc.didMove(toParentViewController: self)
            
            vc.view.frame = self.ContentView.bounds
            self.ContentView.addSubview(vc.view)
            
            self.currentViewController = vc
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let currentViewController = currentViewController {
            currentViewController.viewWillDisappear(animated)
        }
    }
    
    
    @IBAction func switchTabs(_ sender: UISegmentedControl) {
        self.currentViewController!.view.removeFromSuperview()
        self.currentViewController!.removeFromParentViewController()
        
        displayCurrentTab(sender.selectedSegmentIndex)
    }
    
    // func of loading trucks from server
    func loadTruck() {
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_details.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
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
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        //self.pickerDataNew.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new categories to store parseJSON
                        guard let truck_details_array = parseJSON2["truck_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        
                       //self.TruckNameLabel.text = truck_details_array["truck_name"] as! String
                       self.title = truck_details_array["truck_name"] as? String
                        
                        if (truck_details_array["main_photo"] is NSNull) {
                            // url path to image
                            self.TruckImageView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/img/default_logo.png"))
                        }else{
                            // url path to image
                            let def_cat = truck_details_array["main_photo"] as! String
                            
                            self.TruckImageView.imageFromServerURL(urlString: ("http://www.wsi.sa/truckers/public/trucks/\(def_cat)"))
                            
                            
                        }
                        appDelegate.hideIndicator()
                        
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }


}

