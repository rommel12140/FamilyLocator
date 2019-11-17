//
//  MapViewController.swift
//  FamilyLocator
//
//  Created by DEVG-ODI-2552 on 13/11/2019.
//  Copyright © 2019 Action Trainee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var reference = DatabaseReference()
    var markers = Array<GMSMarker>()
    
    //temporary data
    var user: String!
    let users = ["019143","17E28D"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TEMPORARY
        /*==========================================================================*/
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        self.view.addSubview(button)
        /*===========================================================================*/
        
        //create database reference
        reference = Database.database().reference()
        
        //request authorization
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        //enable delegate and location services
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            //enable location and add functions
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            listenToUserLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update current user location
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        self.reference.child("location").child(user as! String).setValue(["longitude": locValue.longitude,"latitude":locValue.latitude])
    }
    
    func listenToUserLocation(){
        for i in users{
            if i != user{ //if not user, do not add marker
                //create marker for user
                var marker = GMSMarker()
                //add all markers (for fitting to bounds/map)
                markers.append(marker)
                //get user name
                var name: String?
                reference.child("users").child("\(i)").observe(.value, with: { (snapshot) in
                    //set name
                    name = (snapshot.value as? AnyObject)?.value(forKey: "firstname") as! String
                }) { print($0) }
                
                //listen for location (longitude and latitude)
                reference.child("location").child("\(i)").observe(.value, with: { (snapshot) in
                    //reset annotations
                    marker.map = nil
                    //set latitude and longitude
                    if let lat = (snapshot.value as? AnyObject)?.value(forKey: "latitude")  as? CLLocationDegrees, let long = (snapshot.value as? AnyObject)?.value(forKey: "longitude") as? CLLocationDegrees{
                        marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long)) //create marker for each user
                        marker.title = name //user name
                        marker.map = self.mapView   //add marker to map
                    }
                    
                }) { print($0) }
            }
        }

    }
    
    
    //revise (not working function)
    func getAddressFromLocation(lat: CLLocationDegrees, long: CLLocationDegrees) -> String {
        let g = GMSGeocoder()
        var locality: String?
        var subLocality: String?
        var country: String?
        var postalCode: String?
        g.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long)) { response , error in
            if let address = response?.firstResult() {
                locality = address.locality
                subLocality = address.subLocality
                country = address.country
                postalCode = address.postalCode
                
            }
        }
        return "\(subLocality),\(locality),\(country),\(postalCode)"
    }
    
    @objc func handleTap(_ sender: UIButton) {
        let bounds = GMSCoordinateBounds()
        for marker in markers{
            print(marker.position.latitude)
            bounds.includingCoordinate(marker.position)
        }
//        let updateFocus = GMSCameraUpdate.fit(bounds)
//        self.mapView.moveCamera(updateFocus)
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 120.0))
    }
    
}

