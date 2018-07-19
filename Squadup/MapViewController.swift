//
//  MapViewController.swift
//  Squadup
//
//  Created by Jack Liu on 7/16/18.
//  Copyright © 2018 Jack Liu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Firebase

import FirebaseStorage


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapObject: MKMapView!
    @IBOutlet weak var searchHere: UITextField!
    
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    //Reference to the database
    let database = Database.database().reference()
    
    //function that updates the users coordinates in firebase. We will try to access these coordinates with a separate function
    @objc func updateUserCoordinates(){
        let userLat = mapObject.userLocation.coordinate.latitude
        database.child("location").child("latitude").setValue(userLat)
        
        let userLon = mapObject.userLocation.coordinate.longitude
        database.child("location").child("longitude").setValue(userLon)
    }
    
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: {(snapshot) in
            print(snapshot)
        })
    }
    
    
    
    //function that fetches the friends coordinates in firebase.
    //    var friendsLat: CLLocationDegrees
    //    var friendsLon: CLLocationDegrees
    //    @objc func fetchFriendsCoordinates(){
    //
    //    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //handles the general location manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //we want the best fucking accuracy
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        users()
        
        
        //Actually set the UIMapObject in the storyboard
        mapObject.delegate = self
        mapObject.mapType = MKMapType.hybrid //MKMapType.satellite works too -> probably shitty? outdated?
        mapObject.isScrollEnabled = true //Allows user to scroll through map
        mapObject.isRotateEnabled = true //Allows user to rotate map screen
        mapObject.isZoomEnabled = true //Allows user to zoom into map screen
        mapObject.showsUserLocation = true //Shows the blinking dot -> maybe we can customize it so friends have different colors to differentiate them
        
        //Converts address string to a coordinate variable
        let geocoder = CLGeocoder()
        var destinationAddress: MKCoordinateSpan = MKCoordinateSpanMake(21.28277, -157.829444)
        geocoder.geocodeAddressString("135 Waverly Place, Mountain View, CA") {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            destinationAddress = MKCoordinateSpanMake (lat!, lon!)
            print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
        }
        let destinationAnnotation = MKPointAnnotation()
        
        self.mapObject.addAnnotation(destinationAnnotation)
        
        
        var friendAnnotation: MKAnnotation
        
        
        
//        database.child("location").observe(.childChanged, with: {(snap: DataSnapshot) -> Void in
//            //placeholder for changing the annotation of the other user
//            print("user has moved")
//        })
        
        
        //Constant update of location with use of a timer
        var gameTimer: Timer!
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateUserCoordinates), userInfo: nil, repeats: true)
        //stops the timer
        //gameTimer.invalidate()
        
        
        
    }
    
    
    //this updates everything when location changes
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        myLocations.append(locations[0] as CLLocation)
        
        //Changes the zoom/view of the map -> can play around with a little with the zoom to look good
        let mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //Sets the region of focus
        let region = MKCoordinateRegionMake(mapObject.userLocation.coordinate, mapSpan)
        //let region = MKCoordinateRegionMakeWithDistance(mapObject.userLocation.coordinate, 500, 500) //This is an alternate method using distance?
        self.mapObject.setRegion(region, animated: false)
        
        //need at least 2 data entries (locations) to setup drawing the line
        if (myLocations.count > 1){
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            mapObject.add(polyline)
        }
    }
    
    func users(){
        let username = ""
        let latitude = 0
        let longitude = 0
        
        let user: [String : AnyObject] = ["latitude" : latitude as AnyObject,
                                          "longitude" : longitude as AnyObject,
                                          "username" : username as AnyObject]
        let databaseReference = Database.database().reference()
        
        databaseReference.child("users").childByAutoId().setValue(user)
    }
}


