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
    
    var friends: [User] = []
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    //Reference to the database
    let database = Database.database().reference()
    let userID = Auth.auth().currentUser!.uid
    //function that updates the users coordinates in firebase. We will try to access these coordinates with a separate function
    
    @objc func updateAndFind(){
        getFriendsFromFirebase()
        updateUserCoordinates()
        viewFriendAnnotation()
    }
    func updateUserCoordinates(){
        
        let userLat = mapObject.userLocation.coordinate.latitude
        database.child("users").child(userID).child("latitude").setValue(userLat)
        
        let userLon = mapObject.userLocation.coordinate.longitude
        database.child("users").child(userID).child("longitude").setValue(userLon)
    }
    
    func getFriendsFromFirebase() {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            var friends = [User]()
            for temp in snapshot.children{
                print(temp)
                var friend = User(snapshot: temp as! DataSnapshot)
                friends.append(friend!)
            }
            self.friends = friends
            self.viewFriendAnnotation()
        })
    }
    
    func viewFriendAnnotation(){
//        let friendUsername = searchFriendsBar.text
//
//        //forloop searching
//        let theUID = database.child("users").child(userID)
//        let friendUser = User(uid: theUID, username: friendUsername!)
        
        let friendFound = friends.filter({ (user) -> Bool in
            user.username == self.searchFriendsBar.text
        })
            
            if friendFound.count == 0{
                print("sukme")
            }
            else{
                 let uid = friendFound[0].uid
                
                var friendLat = friendFound[0].latitude
                var friendLon = friendFound[0].longitude
                let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(friendLat as! CLLocationDegrees, friendLon as! CLLocationDegrees)
                let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
                let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
                self.mapObject.setRegion(region, animated: true)
                let friendAnnotation = MKPointAnnotation()
                friendAnnotation.coordinate = location
                friendAnnotation.title = friendFound[0].username
                friendAnnotation.subtitle = "THIS IS THE LOCATION OF YOUR FRIEND"
                self.mapObject.addAnnotation(friendAnnotation)
                
            }
        }
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getFriendsFromFirebase()
        //This is for hiding the search bar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        
        
        
        
        
        
        //handles the general location manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //we want the best fucking accuracy
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
//        users()
        
        
        //Actually set the UIMapObject in the storyboard
        mapObject.delegate = self
        mapObject.mapType = MKMapType.hybrid //MKMapType.satellite works too -> probably shitty? outdated?
        mapObject.isScrollEnabled = true //Allows user to scroll through map
        mapObject.isRotateEnabled = true //Allows user to rotate map screen
        mapObject.isZoomEnabled = true //Allows user to zoom into map screen
        mapObject.showsUserLocation = true //Shows the blinking dot -> maybe we can customize it so friends have different colors to differentiate them
        
        //Converts address string to a coordinate variable
//        let geocoder = CLGeocoder()
//        var destinationAddress: CLLocationCoordinate2D = CLLocationCoordinate2DMake(21.28277, -157.829444)
//        geocoder.geocodeAddressString("135 Waverly Place, Mountain View, CA") {
//            placemarks, error in
//            let placemark = placemarks?.first
//            let lat = placemark?.location?.coordinate.latitude
//            let lon = placemark?.location?.coordinate.longitude
//            destinationAddress = CLLocationCoordinate2DMake(lat!, lon!)
//            print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
//        }
        
       
        
        //Constant update of location with use of a timer
       // var gameTimer: Timer!
        //gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateAndFind), userInfo: nil, repeats: true)
        //stops the timer
        //gameTimer.invalidate()
        
        
        
    }
    
        @IBOutlet weak var searchFriendsBar: UITextField!
    @IBAction func searchEntered(_ sender: Any) {
        getFriendsFromFirebase()
        updateUserCoordinates()
        
    }

    
    
    
    //this updates everything when location changes
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        myLocations.append(locations[0] as CLLocation)
        
        //Changes the zoom/view of the map -> can play around with a little with the zoom to look good
        let mapSpan: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //Sets the region of focus
        let friendFound = friends.filter({ (user) -> Bool in
            user.username == self.searchFriendsBar.text
        })
        getFriendsFromFirebase()
        updateUserCoordinates()
        var region = MKCoordinateRegion()
        if friendFound.count != 0 {
            var friendLat = friendFound[0].latitude
            var friendLon = friendFound[0].longitude
            let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(friendLat as! CLLocationDegrees, friendLon as! CLLocationDegrees)
            region = MKCoordinateRegionMake(location, mapSpan)
        }
        else {
            region = MKCoordinateRegionMake(mapObject.userLocation.coordinate, mapSpan)
        }
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
    
//    func users(){
//        let latitude = 0
//        let longitude = 0
//
//        let user: [String : AnyObject] = ["latitude" : latitude as AnyObject,
//                                          "longitude" : longitude as AnyObject,]
//        let databaseReference = Database.database().reference()
//
//        databaseReference.child("users").childByAutoId().setValue(user)
//    }
}


