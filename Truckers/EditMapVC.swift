//
//  EditMapVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/10/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MapKit

class EditMapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    var truck_id = ""
    var truck_coorx = 0.0
    var truck_coory = 0.0
    
    @IBOutlet weak var TruckMap: MKMapView!
    @IBOutlet weak var TruckCoorYTxt: UITextField!
    @IBOutlet weak var TruckCoorXTxt: UITextField!

    let annotation = MKPointAnnotation()
    
    let regionRadius: CLLocationDistance = 1000
    var location = CLLocationCoordinate2D()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.showIndicator()
        loadTruck()
        appDelegate.hideIndicator()
        
        self.TruckMap.delegate = self
        
        let initialLocation = CLLocation(latitude: truck_coorx, longitude: truck_coory)
        centerMapOnLocation(location: initialLocation)
        TruckMap.selectAnnotation(TruckMap.annotations[0], animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(EditMapVC.handleTap(_:)))
        tapGesture.delegate = self
        TruckMap.addGestureRecognizer(tapGesture)
        
    }

    func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.ended {
            
            let touchPoint = sender.location(in: TruckMap)
            let touchCoordinate = TruckMap.convert(touchPoint, toCoordinateFrom: TruckMap)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            TruckCoorXTxt.text = String(annotation.coordinate.latitude)
            TruckCoorYTxt.text = String(annotation.coordinate.longitude)
            annotation.title = "موقع العربة الجديد"
            TruckMap.removeAnnotations(TruckMap.annotations)
            TruckMap.addAnnotation(annotation) //drops the pin
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 4.0, regionRadius * 4.0)
        
        annotation.coordinate = location.coordinate
        
        annotation.title = "موقع العربة الحالي"
        //annotation.subtitle = "Truck Mobile"
        
        TruckMap.addAnnotation(annotation)
        TruckMap.setRegion(coordinateRegion, animated: true)
    }
    
    
        
    
    
    
    @IBAction func EditLocation(_ sender: Any) {
        appDelegate.showIndicator()
        EditTruckLocation()
        appDelegate.hideIndicator()
    }

    
    func EditTruckLocation() {
    
    if TruckCoorXTxt.text!.isEmpty || TruckCoorYTxt.text!.isEmpty  {
    }else{
    
        
    let url = NSURL(string: "http://www.wsi.sa/truckers/secure/edit_truck_location.php")!
    
    let truck_id         = self.truck_id
    let truck_coor_x     = TruckCoorXTxt.text!
    let truck_coor_y     = TruckCoorYTxt.text!
       
    var request = URLRequest(url: url as URL)
    request.httpMethod = "POST"
    
    //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = "truck_id=\(truck_id)&coor_x=\(truck_coor_x)&coor_y=\(truck_coor_y)"
    
    // print(body)
    request.httpBody = body.data(using: String.Encoding.utf8)
    
    URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data:Data?, response:URLResponse?, error:Error?)  in
    if error == nil {
    //DispatchQueue.main.async {
    do {
    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
    
    guard let parseJSON = json
    else {
    
    DispatchQueue.main.async(execute: { appDelegate.infoView(message: "عفواً توجد مشكلة بالادخال", color: appRedColor) })
    return
    }
    
    let id = parseJSON["user_id"]
    
    if id != nil {
        
        let message = parseJSON["message"] as! String
        DispatchQueue.main.async(execute: {
            
            appDelegate.infoView(message: message, color: appGreenColor)
    })
    
    
    
    } else {
    
    DispatchQueue.main.async(execute: {
    let message = parseJSON["message"] as! String
    appDelegate.infoView(message: message, color: appRedColor)
    })
    
    }
        //appDelegate.hideIndicator()
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
        appDelegate.hideIndicator()

    }
    
    
    


    // func of loading trucks from server
    func loadTruck() {
        
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
                        
                        // declare new categories to store parseJSON
                        guard let truck_details_array = parseJSON2["truck_all_details"] as? AnyObject else {
                            print("Error while parseJSONing.")
                            return
                        }
                        
                        
                        self.truck_id               = truck_details_array["truck_id"] as! String
                        self.truck_coorx            = (truck_details_array["coor_x"] as! NSString).doubleValue
                        self.truck_coory            = (truck_details_array["coor_y"] as! NSString).doubleValue
                        
                        self.centerMapOnLocation(location: CLLocation(latitude: (truck_details_array["coor_x"] as! NSString).doubleValue, longitude: (truck_details_array["coor_y"] as! NSString).doubleValue))
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    
    

    
}
