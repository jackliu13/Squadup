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
    
    let database = Database.database().reference()
    
    
    @objc func updateUserCoordinates(){
        let userLat = mapObject.userLocation.coordinate.latitude
        database.child("location").child("latitude").setValue(userLat)
        
        let userLon = mapObject.userLocation.coordinate.longitude
        database.child("location").child("longitude").setValue(userLon)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database.child("location").child("longitude").observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.value)
        }
        database.child("location").observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String:AnyObject] ?? [:]
            for i in dict {
                print(i.key)
                print(i.value)
            }
        }
        
        //handles the general location manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest //we want the best fucking accuracy
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()

        
        //Actually set the UIMapObject in the storyboard
        mapObject.delegate = self
        mapObject.mapType = MKMapType.hybrid //MKMapType.satellite works too -> probably shitty? outdated?
        mapObject.isScrollEnabled = true //Allows user to scroll through map
        mapObject.isRotateEnabled = true //Allows user to rotate map screen
        mapObject.isZoomEnabled = true //Allows user to zoom into map screen
        mapObject.showsUserLocation = true //Shows the blinking dot -> maybe we can customize it so friends have different colors to differentiate them
        
        //Converts address string to a coordinate variable
        let geocoder = CLGeocoder()
        var destinationAddress: CLLocationCoordinate2D = CLLocationCoordinate2DMake(21.28277, -157.829444)
        geocoder.geocodeAddressString("135 Waverly Place, Mountain View, CA") {
            placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            destinationAddress = CLLocationCoordinate2DMake(lat!, lon!)
            print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
        }
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationAddress
        
        self.mapObject.addAnnotation(destinationAnnotation)

        //let pathToDestination: MKAnnotation = MKAnnotationView() as! MKAnnotation
        
       
        
        database.child("location").observe(.childChanged, with: {(snap: DataSnapshot) -> Void in
            //placeholder for changing the annotation of the other user
            print("user has moved")
        })
        
        //Constant update of location with use of a timer
        var gameTimer: Timer!
        gameTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateUserCoordinates), userInfo: nil, repeats: true)
        //stops the timer
        //gameTimer.invalidate()

        
        
        
        
        //If a user is added or deleted it will change ...
//        locationRef.observe(.childAdded , with: {(snap: DataSnapshot) -> Void in
//            //placeholder for changing the annotation of the other user
//            print("user was added")
//        })
//        locationRef.observe(.childRemoved, with: {(snap: DataSnapshot) -> Void in
//            //placeholder for changing the annotation of the other user
//            print("user was deleted")
//        })
        
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
    //Pretty cool pathing shit that I stole
//    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
//
//        if overlay is MKPolyline {
//            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
//            polylineRenderer.strokeColor = UIColor.red
//            polylineRenderer.lineWidth = 4
//            return polylineRenderer
//        }
//        return nil
//    }
}


