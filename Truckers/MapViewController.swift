//
//  MapViewController.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/27/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MyAnnotation : MKPointAnnotation {
    var customTruckId : String?
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var AllMapView: MKMapView!
    
    var locations = [AnyObject]()
    
    var my_ann : String?
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AllMapView.delegate = self
        
        
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.shared.isConnectedToNetwork(){
            
            loadTruckLocations()
            
        }else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000)
                AllMapView.setRegion(viewRegion, animated: false)
            }
        }
    }
    
    
    // func of loading categories from server
    func loadTruckLocations() {
        appDelegate.showIndicator()
        // accessing php file via url path
        let url2 = URL(string: "http://www.wsi.sa/truckers/secure/get_trucks_locations.php")!
        
        // declare request to proceed php file
        var request2 = URLRequest(url: url2)
        
        // declare method of passing information to php file
        request2.httpMethod = "POST"
        
        
        // launch session
        URLSession.shared.dataTask(with: request2) { data, response, error in
            
            // get main queue to operations inside of this block
            DispatchQueue.main.async(execute: {
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json2 = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        self.locations.removeAll(keepingCapacity: false)
                        
                        
                        // declare new parseJSON to store json
                        guard let parseJSON2 = json2 else {
                            print("Error while parsing")
                            return
                        }
                        
                        let status = parseJSON2["status"] as! String
                        // if there is some message - post is made
                        if status == "200" {
                            // declare new categories to store parseJSON
                            guard let trucks_locations = parseJSON2["trucks_locations"] as? [AnyObject] else {
                                print("Error while parseJSONing.")
                                return
                            }
                            
                            self.locations = trucks_locations
                            
                            for location in self.locations {
                                
                                let annotation:MyAnnotation = MyAnnotation()
                                annotation.title = location["truck_name"] as? String
                                annotation.customTruckId = location["truck_id"] as? String
                                annotation.coordinate = CLLocationCoordinate2D(latitude: (location["coor_x"] as! NSString).doubleValue, longitude: (location["coor_y"] as! NSString).doubleValue)
                                
                                self.AllMapView.addAnnotation(annotation)
                                
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
                        
                        appDelegate.hideIndicator()
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }
    

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "TruckDetailsVC") as! TruckDetailsVC
            
            let TruckAnnotation = view.annotation as? MyAnnotation
            
            desController.truck_id = (TruckAnnotation?.customTruckId!)!
            
            show(desController, sender: self)
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "truck_pin.png")
        }
        
        return annotationView
    }

    
    


}

