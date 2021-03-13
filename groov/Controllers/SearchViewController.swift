//
//  SearchViewController.swift
//  groov
//
//  Created by Alice Wu on 2/12/21.
//

import UIKit
import SwiftUI
import MapKit
import CoreLocation
import AVFoundation
import Firebase

class SearchViewController: UIViewController {

    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toLogoutButton: UIButton!
    @IBOutlet private var mapView: MKMapView!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        player = AVPlayer(playerItem: playerItem)
        mapView.delegate = self
        
        updateUserLocation()
        getUserInfo()
        locateOtherUsers()
        
        self.toLogoutButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
                                        
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
            
            db.collection("users").document(Auth.auth().currentUser!.uid).setData(["geopoint": GeoPoint(latitude: userLocation.latitude,longitude: userLocation.longitude)], merge: true)
        }
    }
    
    private func updateUserCurrentTrack(with model: CurrentTrack) {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(["currentTrackName": model.item.name, "currentTrackArtist": model.item.album.artists[0].name, "currentTrackImage": model.item.album.images[0].url, "currentTrackPreview": model.item.preview_url], merge: true)
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
    
    private func locateOtherUsers() {
        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        let geopoint1 = GeoPoint(latitude: northEast.latitude, longitude: northEast.longitude)
        let geopoint2 = GeoPoint(latitude: southWest.latitude, longitude: southWest.longitude)

        let dbRef = Firestore.firestore().collection("users")
        let query = dbRef
            .whereField("geopoint", isLessThan: geopoint1)
            .whereField("geopoint", isGreaterThan: geopoint2)

        query.getDocuments { snapshot, error in
            for document in snapshot!.documents {
                if document.documentID != Auth.auth().currentUser?.uid {
                    let userGeopoint = document.get("geopoint") as! GeoPoint
                    
                    if (document.get("currentTrackImage") != nil) {
                        let userID = document.documentID
                        let trackImage = document.get("currentTrackImage") as! String
                        let trackPreview = document.get("currentTrackPreview") as! String
                        let trackName = document.get("currentTrackName") as! String
                        let trackArtist = document.get("currentTrackArtist") as! String
                        
                        let annotation = CustomAnnotation(
                            userID: "\(userID)",
                            trackName: "\(trackName)",
                            trackArtist: "\(trackArtist)",
                            trackImage: "\(trackImage)",
                            trackPreview: "\(trackPreview)",
                            coordinate: CLLocationCoordinate2D(latitude: userGeopoint.latitude, longitude: userGeopoint.longitude))
                        
                        self.mapView.addAnnotation(annotation)
                    }
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
    
    @IBAction func toLogoutButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: .main)

        if let loginViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = loginViewController
            view.window?.makeKeyAndVisible()
        }
    }
}

extension SearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
        
        let identifier = "annotation"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            let trackImageURL = NSURL(string: annotation.trackImage!)
            let trackData = NSData(contentsOf:trackImageURL! as URL)
            let playButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
            playButton.setBackgroundImage(UIImage(data:trackData! as Data), for: .normal)
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playButton.tintColor = UIColor.systemIndigo
            view.leftCalloutAccessoryView = playButton
            let likeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 30)))
            likeButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = UIColor.systemPink
            view.rightCalloutAccessoryView = likeButton
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CustomAnnotation else {
            return
        }
        
        if view.leftCalloutAccessoryView == control {
            if self.player?.rate == 0 {
                print("yuh")
                let trackPreviewURL = URL(string: annotation.trackPreview!)
                let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                self.player = AVPlayer(playerItem: playerItem)
                self.player?.play()
                let trackImageURL = NSURL(string: annotation.trackImage!)
                let trackData = NSData(contentsOf:trackImageURL! as URL)
                let playButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
                playButton.setBackgroundImage(UIImage(data:trackData! as Data), for: .normal)
                playButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                playButton.tintColor = UIColor.systemIndigo
                view.leftCalloutAccessoryView = playButton
           } else {
                self.player?.pause()
                let trackImageURL = NSURL(string: annotation.trackImage!)
                let trackData = NSData(contentsOf:trackImageURL! as URL)
                let playButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
                playButton.setBackgroundImage(UIImage(data:trackData! as Data), for: .normal)
                playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                playButton.tintColor = UIColor.systemIndigo
                view.leftCalloutAccessoryView = playButton
           }
        } else {
            let db = Firestore.firestore()
            
            // check if other user (user b) has also liked current user's (user a) tracks
            let userA = (Auth.auth().currentUser?.uid)!
            let userB = annotation.userID!
            db.collection("users").document(userB).getDocument { (snapshot, error) in
                if let document = snapshot {
                    let likesArray = document.get("likes") as! Array<String>
                    let matchesArray = document.get("matches") as! Array<String>
                    
                    if likesArray.contains(userA) {
                        // if user a and user b like eachother's tracks, then they are matched together
                        db.collection("users").document(userA).updateData(["matches": FieldValue.arrayUnion(["\(String(describing: userB))"])])
                        db.collection("users").document(userB).updateData(["matches": FieldValue.arrayUnion(["\(String(describing: userA))"])])
                        db.collection("users").document(userB).updateData(["likes": FieldValue.arrayRemove(["\(String(describing: userA))"])])
                    } else if matchesArray.contains(userA) == false {
                        // if not and the users aren't already matched to eachother, then user b is added to user a's list of liked users
                        db.collection("users").document(userA).updateData(["likes": FieldValue.arrayUnion(["\(String(describing: userB))"])])
                    }
                }
            }
        }
    }
}
