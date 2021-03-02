//
//  SearchViewController.swift
//  groov
//
//  Created by Alice Wu on 2/12/21.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class SearchViewController: UIViewController {

    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toSettingsButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        updateUserLocation()
        getUserInfo()
        super.viewDidLoad()
    }
    
    private func updateUserLocation() {
        let db = Firestore.firestore()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(viewRegion, animated: false)
            
            db.collection("users").document(Auth.auth().currentUser!.uid).setData(["latitude": userLocation.latitude, "longitude": userLocation.longitude], merge: true)
        }
    }
    
    private func updateUserCurrentTrack(with model: CurrentTrack) {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("tracks").document("currentTrack").setData(["trackName": model.item.name, "trackArtist": model.item.album.artists[0].name, "trackImage": model.item.album.images[0].url, "trackPreview": model.item.preview_url], merge: true)
    }
    
    private func updateUserTopTracks(with model: RankedTrack) {
        let db = Firestore.firestore()
        
        for i in 1...5 {
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("tracks").document("rankedTrack"+String(i)).setData(["trackName": model.items[i-1].name, "trackArtist": model.items[i-1].album.artists[0].name, "trackImage": model.items[i-1].album.images[0].url, "trackPreview": model.items[i-1].preview_url], merge: true)
        }
    }
    
    private func getUserInfo() {
        APICaller.shared.getCurrentTrack { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.updateUserCurrentTrack(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        APICaller.shared.getTopTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.updateUserTopTracks(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
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
