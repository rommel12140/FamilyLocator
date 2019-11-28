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
import MapKit
import MaterialComponents.MDCFloatingButton

struct ButtonProperties {
    var buttonSize: CGFloat!
    var offset: CGFloat!
    var currentYPosition: CGFloat!
    var rightMargin: CGFloat!
}

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    let googleApiKey = "AIzaSyDxSgGQX6jrn4iq6dyIWAKEOTneZ3Z8PtU"
    var reference = DatabaseReference()
    var buttonProperties = ButtonProperties()
    var markers = Array<GMSMarker>()
    var polylines = Array<GMSPolyline>()
    let locationManager = CLLocationManager()
    var observationsrc: NSKeyValueObservation?
    var observationdst: NSKeyValueObservation?
    var userLocation: CLLocation!
    var isRouting: Bool = false
    var buffer: Bool = false
    //temporary data
    var user: String!
    var users: Array<String>!
    var userIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create database reference
        reference = Database.database().reference()
        
        //insert user to users
        //users.append(user)
        
        //request authorization
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        //enable delegate and location services
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            createButtons()
            listenToUserLocation()
            
            //enable location and add functions
            mapView.delegate = self
            mapView.isMyLocationEnabled = true
            mapView.settings.tiltGestures = false
            mapView.settings.myLocationButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: buttonProperties.buttonSize+buttonProperties.offset, right: 0)
            
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update current user location
        self.userLocation = (manager.location)!
        self.reference.child("location").child(user as! String).setValue(["longitude": userLocation.coordinate.longitude,"latitude":userLocation.coordinate.latitude])
        
    }
    
    func listenToUserLocation(){
        //listen to each user
        for (index,element) in users.enumerated(){
            if true { //if not user, do not add marker
                
                //initialize a marker
                var marker = GMSMarker()
                marker.tracksInfoWindowChanges = true;
                markers.append(marker)
                
                if element == user{
                    userIndex = index
                }
                
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
                            marker.accessibilityLabel = "\(element)"
                            marker.accessibilityValue = "\(index)"
                        }
                        else{
                            CATransaction.begin()
                            CATransaction.setAnimationDuration(0.1)
                            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            CATransaction.commit()
                        }
                        
                        //get the address
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
                        
                        //focus on user if selected and not routing
                        if self.mapView.selectedMarker == marker, self.isRouting == false{
                            self.mapView.animate(to: GMSCameraPosition(latitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 17))
                        }
                        
                    }
                }) { print($0) }
            }
        }

    }
    
    func createButtons(){
        //set button properties
        //buttonProperties.buttonSize = CGFloat(75)
        buttonProperties.buttonSize = CGFloat(view.frame.width/6)
        buttonProperties.offset = CGFloat(buttonProperties.buttonSize/5)
        buttonProperties.currentYPosition = CGFloat(0)
        buttonProperties.rightMargin = CGFloat(buttonProperties.buttonSize/5)
        buttonProperties.currentYPosition = viewAllUsersButton(buttonSize: buttonProperties.buttonSize, yPos: buttonProperties.currentYPosition, rightMargin: buttonProperties.rightMargin, offset: buttonProperties.offset)
        
        for (index,element) in users.enumerated() {
            if true{
                //create button for each user
                buttonProperties.currentYPosition = userButton(buttonSize: buttonProperties.buttonSize, yPos: buttonProperties.currentYPosition, rightMargin: buttonProperties.rightMargin, index: index, offset: buttonProperties.offset)
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
    
    func viewAllUsersButton(buttonSize: CGFloat, yPos: CGFloat, rightMargin: CGFloat, offset: CGFloat) -> CGFloat{
        let yPosition = buttonSize + yPos
        let xFrame = self.view.frame.maxX - buttonSize - rightMargin
        let yFrame = (self.view.frame.minY) + yPosition
        let button = MDCFloatingButton(frame: CGRect(x: xFrame, y: yFrame , width: buttonSize, height: buttonSize))
        button.setTitle("View All", for: .normal)
        button.titleLabel!.numberOfLines = 1
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        button.titleLabel!.baselineAdjustment = .alignCenters
        button.setBackgroundColor(UIColor.commonGreenColor())
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(viewAll), for: .touchUpInside)
        self.view.addSubview(button)
        
        return yPosition + offset
    }
    
    func userButton(buttonSize: CGFloat, yPos: CGFloat, rightMargin: CGFloat, index: Int, offset: CGFloat) -> CGFloat{
        let yPosition = buttonSize + yPos
        let xFrame = self.view.frame.maxX - buttonSize - rightMargin
        let yFrame = (self.view.frame.minY) + yPosition
        let button = MDCFloatingButton(frame: CGRect(x: xFrame, y: yFrame , width: buttonSize, height: buttonSize))
        button.setTitle(users[index], for: .normal)
        button.tag = index
        button.setBackgroundColor(UIColor.commonGreenColor())
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(viewUser), for: .touchUpInside)
        self.view.addSubview(button)
        
        return yPosition + offset
    }
    
    @objc func viewAll() {
        var bounds = GMSCoordinateBounds()
        for marker in markers
        {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 17)
        mapView.selectedMarker = nil
        mapView.animate(with: update)
    }
    
    @objc func viewUser(_ sender: UIButton) {
        self.mapView.animate(to: GMSCameraPosition(latitude: markers[sender.tag].position.latitude, longitude: markers[sender.tag].position.longitude, zoom: 17))
        mapView.selectedMarker = markers[sender.tag]
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let markerID = Int(marker.accessibilityValue!)
        if userLocation?.coordinate != nil{
            if let src = userLocation!.coordinate as? CLLocationCoordinate2D{
                var bounds = GMSCoordinateBounds()
                bounds = bounds.includingCoordinate(src)
                bounds = bounds.includingCoordinate(marker.position)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 17)
                mapView.animate(with: update)
                //initialize
                self.fetchRoute(src: src, dst: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
                //update
                self.observationdst = markers[markerID!].observe(
                    \.position,
                    options: [.old, .new]
                ) { object, change in
                    if let lat = (change.newValue?.latitude), let long = (change.newValue?.longitude){
                        self.fetchRoute(src: src, dst: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    }
                }
                self.observationdst = markers[userIndex!].observe(
                    \.position,
                    options: [.old, .new]
                ) { object, change in
                    if let lat = (change.newValue?.latitude), let long = (change.newValue?.longitude){
                        self.fetchRoute(src: src, dst: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    }
                }
                
            }
        }
        
    }
    
    func fetchRoute(src: CLLocationCoordinate2D, dst: CLLocationCoordinate2D){
        self.isRouting = true
        let source = MKMapItem(placemark: MKPlacemark(coordinate: src))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: dst))
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { (response, error) in
            if response != nil{
                var coordinates = [CLLocationCoordinate2D](
                    repeating: kCLLocationCoordinate2DInvalid,
                    count: response!.routes[0].polyline.pointCount
                )
                response!.routes[0].polyline.getCoordinates(
                    &coordinates,
                    range: NSRange(location: 0, length: response!.routes[0].polyline.pointCount)
                )
                
                if let resp = response{
                    self.show(polylines: self.googlePolylines(from: resp))
                }
            }
            if error != nil{
//                let alert = UIAlertController(title: "Error",
//                                              message: error?.localizedDescription,
//                                              preferredStyle: .alert)
//
//                //alert with error
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    private func googlePolylines(from response: MKDirections.Response) -> [GMSPolyline] {
        let polylines: [GMSPolyline] = response.routes.map({ route in
            var coordinates = [CLLocationCoordinate2D](
                repeating: kCLLocationCoordinate2DInvalid,
                count: route.polyline.pointCount
            )
            route.polyline.getCoordinates(
                &coordinates,
                range: NSRange(location: 0, length: route.polyline.pointCount)
            )
            let polyline = Polyline(coordinates: coordinates)
            let encodedPolyline: String = polyline.encodedPolyline
            let path = GMSPath(fromEncodedPath: encodedPolyline)
            return GMSPolyline(path: path)
        })
        return polylines
    }
    
    func show(polylines: [GMSPolyline]) {
        self.polylines.forEach { polyline in
            polyline.map = nil
        }
        self.polylines = polylines
        self.polylines.forEach { polyline in
            let strokeStyles = [
                GMSStrokeStyle.solidColor(UIColor.commonGreenColor()),
                GMSStrokeStyle.solidColor(.clear)
            ]
            let strokeLengths = [
                NSNumber(value: 10),
                NSNumber(value: 6)
            ]
            if let path = polyline.path {
                polyline.spans = GMSStyleSpans(path, strokeStyles, strokeLengths, .rhumb)
            }
            polyline.strokeWidth = 3
            polyline.map = mapView
        }
        
    }
}
