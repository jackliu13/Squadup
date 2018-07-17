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


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapObject: MKMapView!
    @IBOutlet weak var searchHere: UITextField!
    
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString("your address") {
//            placemarks, error in
//            let placemark = placemarks?.first
//            let lat = placemark?.location?.coordinate.latitude
//            let lon = placemark?.location?.coordinate.longitude
//            var destinationAddress: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, lon!)
//            print("Lat: \(lat), Lon: \(lon)")
//        }
//        let destinationAnnotation = MKPointAnnotation()
//        destinationAnnotation.coordinate = destinationAddress
//        destinationAnnotation.title = "SquadUpSpot"
//        self.mapObject.addAnnotation(destinationAnnotation)
//
//        let pathToDestination: MKAnnotation = MKAnnotationView() as! MKAnnotation
        
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
    func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        return nil
    }
}


