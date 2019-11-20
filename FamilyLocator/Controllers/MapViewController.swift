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
import MaterialComponents.MDCFloatingButton

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
            mapView.settings.tiltGestures = false
            listenToUserLocation()
        }
        
        //create all customized buttons
        let buttonSize = CGFloat(75)
        var offset = CGFloat(20)
        let rightMargin = CGFloat(10)
        offset = viewAllMarkersButton(buttonSize: buttonSize, offset: offset, rightMargin: rightMargin)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update current user location
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        self.reference.child("location").child(user as! String).setValue(["longitude": locValue.longitude,"latitude":locValue.latitude])
    }
    
    func listenToUserLocation(){
        for (index,element) in users.enumerated(){
            if true{ //if not user, do not add marker
                //create marker for user
                var marker = GMSMarker()
                //add all markers (for fitting to bounds/map)
                
                //get user name
                var name: String?
                reference.child("users").child("\(element)").observe(.value, with: { (snapshot) in
                    //set name
                    name = (snapshot.value as? AnyObject)?.value(forKey: "firstname") as! String
                }) { print($0) }
                
                //listen for location (longitude and latitude)
                reference.child("location").child("\(element)").observe(.value, with: { (snapshot) in
                    //reset annotations
                    marker.map = nil
                    //set latitude and longitude
                    if let lat = (snapshot.value as? AnyObject)?.value(forKey: "latitude")  as? CLLocationDegrees, let long = (snapshot.value as? AnyObject)?.value(forKey: "longitude") as? CLLocationDegrees{
                        print(lat)
                        print(long)
                        marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long)) //create marker for each user
                        self.markers.insert(marker, at: index)
                        marker.title = name //user name
                        marker.icon = UIImage.resizeImage(image: UIImage(named: "logo")!, targetSize: CGSize.init(width: 70, height: 70))
                        
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
    
    func viewAllMarkersButton(buttonSize: CGFloat, offset: CGFloat, rightMargin: CGFloat) -> CGFloat{
        let xFrame = self.view.frame.maxX - buttonSize - rightMargin
        let yFrame = (self.view.frame.minY + 20) + buttonSize + offset
        let button = MDCFloatingButton(frame: CGRect(x: xFrame, y: yFrame , width: buttonSize, height: buttonSize))
        
        button.setTitle("All", for: .normal)
        button.setBackgroundColor(UIColor.commonGreenColor())
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(viewAll), for: .touchUpInside)
        self.view.addSubview(button)
        
        return buttonSize + offset
    }
    
    @objc func viewAll(_ sender: UIButton) {
        print("tap")
        let bounds = GMSCoordinateBounds()
        for marker in markers{
            print(marker)
            bounds.includingCoordinate(marker.position)
        }
        let updateFocus = GMSCameraUpdate.fit(bounds)
        self.mapView.moveCamera(updateFocus)
    }
    

    
}















//func drawText(text:NSString, inImage:UIImage) -> UIImage? {
//
//    let font = UIFont.systemFont(ofSize: 11)
//    let size = inImage.size
//
//    //UIGraphicsBeginImageContext(size)
//    let scale = UIScreen.main.scale
//    UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
//    inImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//    let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
//    style.alignment = .center
//    let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black ]
//
//    let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
//    let rect = CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height)
//    let textRect = CGRect(x: (rect.size.width - textSize.width)/2, y: (rect.size.height - textSize.height)/2 - 2, width: textSize.width, height: textSize.height)
//    text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
//    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
//
//    UIGraphicsEndImageContext()
//
//    return resultImage
//}
