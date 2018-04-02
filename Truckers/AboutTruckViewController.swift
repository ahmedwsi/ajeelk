//
//  AboutTruckViewController.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/18/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import MapKit

class AboutTruckViewController: UIViewController , MKMapViewDelegate {

    @IBOutlet weak var TruckEmailLbl: UILabel!
    @IBOutlet weak var TruckMobileLbl: UILabel!
    @IBOutlet weak var TruckWorkTeamLbl: UILabel!
    @IBOutlet weak var TruckStatusLbl: UILabel!
    @IBOutlet weak var TruckDetailsLbl: UILabel!
    
    @IBOutlet weak var TruckMapLocation: MKMapView!
    
    var truck_id1 = ""
    var truck_name = ""
    
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    let annotation = MKPointAnnotation()
    
    let regionRadius: CLLocationDistance = 1000
    var location = CLLocationCoordinate2D()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let parentV = self.parent as! TruckDetailsVC
        
        truck_id1 = parentV.truck_id
        
        loadTruck2()
        
        self.TruckMapLocation.delegate = self
        
        centerMapOnLocation(location: initialLocation)
        TruckMapLocation.selectAnnotation(TruckMapLocation.annotations[0], animated: true)

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,regionRadius * 2.0, regionRadius * 2.0)
        
        annotation.coordinate = location.coordinate
        annotation.title = "اذهب الآن لموقع العربة"
        //annotation.subtitle = "Truck Mobile"
        
        TruckMapLocation.addAnnotation(annotation)
        TruckMapLocation.setRegion(coordinateRegion, animated: true)
    }

    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let customURL = URL(string:"comgooglemaps://?saddr=&daddr=\(annotation.coordinate.latitude),\(annotation.coordinate.longitude)&directionsmode=driving")
            
            if UIApplication.shared.canOpenURL(customURL!) {
                //UIApplication.shared.openURL(NSURL(string: customURL)! as URL)
                UIApplication.shared.open( customURL!, options: [:], completionHandler: nil)
            }
            else {
                let alert = UIAlertController(title: "Error", message: "Google maps not installed", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated:true, completion: nil)
            }
        
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
    
    
    // func of loading trucks from server
    func loadTruck2() {
        appDelegate.showIndicator()
        // accessing php file via url path
        let url = URL(string: "http://www.wsi.sa/truckers/secure/get_truck_details.php")!
        
        // declare request to proceed php file
        var request = URLRequest(url: url)
        
        // declare method of passing information to php file
        request.httpMethod = "POST"
        
        // pass information to php file
        let body = "truck_id=\(truck_id1)"

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
                        
                        
                        self.TruckEmailLbl.text     = truck_details_array["truck_email"] as? String
                        self.TruckMobileLbl.text    = truck_details_array["truck_mobile"] as? String
                        self.TruckDetailsLbl.text   = truck_details_array["truck_details"] as? String
                        self.truck_name             = truck_details_array["truck_name"] as! String
                        
                        if (truck_details_array["work_team"] as! String == "1")
                        {
                            self.TruckWorkTeamLbl.text = "رجال"
                        }else{
                            self.TruckWorkTeamLbl.text = "نساء"
                        }
                        
                        if (truck_details_array["truck_stable"] as! String == "1")
                        {
                            self.TruckStatusLbl.text = "ثابتة"
                        }else{
                            self.TruckStatusLbl.text = "متحركة"
                        }
                        
                        self.centerMapOnLocation(location: CLLocation(latitude: (truck_details_array["coor_x"] as! NSString).doubleValue, longitude: (truck_details_array["coor_y"] as! NSString).doubleValue))
                        
                        appDelegate.hideIndicator()
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
            }.resume()
        
    }

    

}
