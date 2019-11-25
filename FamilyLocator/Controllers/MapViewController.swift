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

struct ButtonProperties {
    var buttonSize: CGFloat!
    var offset: CGFloat!
    var rightMargin: CGFloat!
}

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    let googleApiKey = "AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU"
    var reference = DatabaseReference()
    var buttonProperties = ButtonProperties()
    var markers = Array<GMSMarker>()
    var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    //temporary data
    var user: String!
    var users: NSMutableArray = []
    
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
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            
            mapView.settings.tiltGestures = false
            mapView.settings.myLocationButton = true
            
            createButtons()
            listenToUserLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update current user location
        let locValue: CLLocationCoordinate2D = (manager.location?.coordinate)!
        self.reference.child("location").child(user as! String).setValue(["longitude": locValue.longitude,"latitude":locValue.latitude])
        userLocation = locValue
    }
    
    func listenToUserLocation(){
        //listen to each user
        for (index,element) in users.enumerated(){
            if true { //if not user, do not add marker
                
                //initialize a marker
                var marker = GMSMarker()
                marker.tracksInfoWindowChanges = true;
                markers.append(marker)
                
                //add all markers (for fitting to bounds/map)
                //get user name
                var name: String?
                reference.child("users").child("\(element)").observe(.value, with: { (snapshot) in
                    //set name
                    name = (snapshot.value as AnyObject).value(forKey: "firstname") as? String
                }) { print($0) }
                
                //listen for location (longitude and latitude)
                reference.child("location").child("\(element)").observe(.value, with: { (snapshot) in
                    
                    //set latitude and longitude
                    if let lat = (snapshot.value as AnyObject).value(forKey: "latitude")  as? CLLocationDegrees, let long = (snapshot.value as AnyObject).value(forKey: "longitude") as? CLLocationDegrees{
                        //update marker for each user
                        if marker.accessibilityLabel == nil{
                            marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: long))
                            self.markers[index] = marker
                            marker.appearAnimation = GMSMarkerAnimation.pop
                            marker.icon = UIImage.resizeImage(image: UIImage(named: "logo")!, targetSize: CGSize.init(width: 70, height: 70))
                            marker.map = self.mapView   //add marker to map
                            marker.snippet = name
                            marker.accessibilityLabel = "\(index)"
                        }
                        else{
                            CATransaction.begin()
                            CATransaction.setAnimationDuration(0.1)
                            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            CATransaction.commit()
                        }
                        
                        let g = GMSGeocoder()
                        g.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)) { response , error in
                            if let address = response?.firstResult() {
                                var dict = [String: String]()
                                dict["city"] = address.locality
                                dict["country"] = address.country
                                dict["street"] = address.thoroughfare
                                marker.userData = dict
                            }
                        }
                        
                        if self.mapView.selectedMarker == marker{
                            self.mapView.animate(to: GMSCameraPosition(latitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 50))
                        }
                        
                    }
                }) { print($0) }
            }
        }

    }
    
    func createButtons(){
        //set button properties
        buttonProperties.buttonSize = CGFloat(75)
        buttonProperties.offset = CGFloat(20)
        buttonProperties.rightMargin = CGFloat(10)
        buttonProperties.offset = viewAllUsersButton(buttonSize: buttonProperties.buttonSize, offset: buttonProperties.offset, rightMargin: buttonProperties.rightMargin)
        
        for (index,element) in users.enumerated() {
            if true{
                //create button for each user
                buttonProperties.offset = userButton(buttonSize: buttonProperties.buttonSize, offset: buttonProperties.offset, rightMargin: buttonProperties.rightMargin, index: index)
                buttonProperties.offset += CGFloat(20)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        let customInfoWindow = Bundle.main.loadNibNamed("MapInfo", owner: self, options: nil)![0] as! MapInfo
        var addressInfo = NSDictionary()
        
        if let info = marker.userData as? NSDictionary{
            addressInfo = info
        }
        
        customInfoWindow.userName.text = marker.snippet
        customInfoWindow.userNumber = marker.accessibilityLabel
        customInfoWindow.layer.cornerRadius = customInfoWindow.layer.frame.height/4
        
        if let street = addressInfo["street"] as? String{
            customInfoWindow.userStreet.text = street
        }
        else{
            customInfoWindow.userStreet.text = "--"
        }
        if let city = addressInfo["city"] as? String{
            customInfoWindow.userCity.text = city
        }
        else{
            customInfoWindow.userCity.text = "--"
        }
        if let country = addressInfo["country"] as? String{
            customInfoWindow.userCountry.text = country
        }
        else{
            customInfoWindow.userCountry.text = "--"
        }
        
        return customInfoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("tapped")
        if userLocation != nil{
            print("Routing")
            //fetchRoute(src: userLocation!, dst: marker.position)
        }
    }
    
    func viewAllUsersButton(buttonSize: CGFloat, offset: CGFloat, rightMargin: CGFloat) -> CGFloat{
        let xFrame = self.view.frame.maxX - buttonSize - rightMargin
        let yFrame = (self.view.frame.minY + 20) + buttonSize + offset
        let button = MDCFloatingButton(frame: CGRect(x: xFrame, y: yFrame , width: buttonSize, height: buttonSize))
        button.setTitle("View All", for: .normal)
        button.setBackgroundColor(UIColor.commonGreenColor())
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(viewAll), for: .touchUpInside)
        self.view.addSubview(button)
        
        return buttonSize + offset*2
    }
    
    func userButton(buttonSize: CGFloat, offset: CGFloat, rightMargin: CGFloat, index: Int) -> CGFloat{
        let xFrame = self.view.frame.maxX - buttonSize - rightMargin
        let yFrame = (self.view.frame.minY + 20) + buttonSize + offset
        let button = MDCFloatingButton(frame: CGRect(x: xFrame, y: yFrame , width: buttonSize, height: buttonSize))
        button.setTitle((users[index] as! String), for: .normal)
        button.tag = index
        button.setBackgroundColor(UIColor.commonGreenColor())
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(viewUser), for: .touchUpInside)
        self.view.addSubview(button)
        
        return buttonSize + offset
    }
    
    @objc func viewAll() {
        var bounds = GMSCoordinateBounds()
        for marker in markers
        {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.selectedMarker = nil
        mapView.animate(with: update)
    }
    
    @objc func viewUser(_ sender: UIButton) {
        self.mapView.animate(to: GMSCameraPosition(latitude: markers[sender.tag].position.latitude, longitude: markers[sender.tag].position.longitude, zoom: 50))
        mapView.selectedMarker = markers[sender.tag]
    }
    
    func fetchRoute(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D){
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(src.latitude),\(src.longitude)&destination=\(dst.latitude),\(dst.longitude)&sensor=false&mode=walking&key=\(googleApiKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    if let json : [String:Any] = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        print(json)
                        let preRoutes = json["routes"] as! NSArray
                        let routes = preRoutes[0] as! NSDictionary
                        let routeOverviewPolyline:NSDictionary = routes.value(forKey: "overview_polyline") as! NSDictionary
                        let polyString = routeOverviewPolyline.object(forKey: "points") as! String
                        
                        DispatchQueue.main.async(execute: {
                            let path = GMSPath(fromEncodedPath: polyString)
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 5.0
                            polyline.strokeColor = UIColor.green
                            polyline.map = self.mapView
                        })
                    }
                    
                } catch {
                    print("parsing error")
                }
            }
        })
        task.resume()
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
