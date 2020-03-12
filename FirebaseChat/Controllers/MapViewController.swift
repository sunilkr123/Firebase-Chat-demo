//
//  MapViewController.swift
//  iChat
//
//  Created by David Kababyan on 24/06/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    var location: CLLocation!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map"

        setupUI()
        createRightButton()
    }
    
    //MARK: SetupUI
    
    func setupUI() {
        
        var region = MKCoordinateRegion()
        
        region.center.latitude = location.coordinate.latitude
        region.center.longitude = location.coordinate.longitude
        
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01

        mapView.setRegion(region, animated: false)
        mapView.showsUserLocation = true
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    //MARK: OpenInMaps
    
    func createRightButton() {
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Open in Maps", style: .plain, target: self, action: #selector(self.openInMap))]
    }

    
    @objc func openInMap() {
        
        let regionDestination: CLLocationDistance = 10000
        
        let coordinates = location.coordinate
        
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDestination, longitudinalMeters: regionDestination)

        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:  regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "User's Location"
        mapItem.openInMaps(launchOptions: options)
    }



}
