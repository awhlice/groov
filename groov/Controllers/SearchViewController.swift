//
//  SearchViewController.swift
//  groov
//
//  Created by Alice Wu on 2/12/21.
//

import UIKit
import MapKit
import CoreLocation

class SearchViewController: UIViewController {

    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toSettingsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(viewRegion, animated: false)
        }
    }
    
    @IBAction func toProfileButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: .main)

        if let profileViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = profileViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func toMatchesButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Matches", bundle: .main)

        if let matchesViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = matchesViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func toSettingsButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: .main)

        if let settingsViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = settingsViewController
            view.window?.makeKeyAndVisible()
        }
    }
}
