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

    // MARK: - Subviews
    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toLogoutButton: UIButton!
    @IBOutlet private var mapView: MKMapView!
    
    var db: Firestore!
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        self.toLogoutButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
                                        
        player = AVPlayer(playerItem: playerItem)
        mapView.delegate = self
        
        db = Firestore.firestore()
        
        updateUserLocation()
        getUserInfo()
        locateOtherUsers()
        
        super.viewDidLoad()
    }
    
    // displays a popup alert with a specified title and message
    func showAlert(Title : String!, Message : String!)  -> UIAlertController {
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default)

        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame

        return alertController
      }
    
    // updates the user's location in the database and pinned location on the map
    private func updateUserLocation() {
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
    
    // updates the user's currently playing track in the database
    private func updateUserCurrentTrack(with model: CurrentTrack) {
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(["currentTrackName": model.item.name, "currentTrackArtist": model.item.album.artists[0].name, "currentTrackImage": model.item.album.images[0].url, "currentTrackPreview": model.item.preview_url], merge: true)
    }
    
    // updates the user's top five most played tracks in the database
    private func updateUserTopTracks(with model: RankedTrack) {
        for i in 1...5 {
            db.collection("users").document(Auth.auth().currentUser!.uid).collection("tracks").document("rankedTrack"+String(i)).setData(["trackName": model.items[i-1].name, "trackArtist": model.items[i-1].album.artists[0].name, "trackImage": model.items[i-1].album.images[0].url, "trackPreview": model.items[i-1].preview_url], merge: true)
        }
    }
    
    // updates the users current track listening info in the database
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
    
    // pins the location of nearby Groov users on the map and retrieves info for the track they're currently listening to populate their annotation popups; avoids pinning the location of users who have already matched with the current user for privacy purposes
    private func locateOtherUsers() {
        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        let geopoint1 = GeoPoint(latitude: northEast.latitude, longitude: northEast.longitude)
        let geopoint2 = GeoPoint(latitude: southWest.latitude, longitude: southWest.longitude)

        let dbRef = db.collection("users")
        let query = dbRef
            .whereField("geopoint", isLessThan: geopoint1)
            .whereField("geopoint", isGreaterThan: geopoint2)

        query.getDocuments { snapshot, error in
            if snapshot?.isEmpty == false {
                for document in snapshot!.documents {
                    if document.documentID != Auth.auth().currentUser?.uid {
                        let userGeopoint = document.get("geopoint") as! GeoPoint
                        
                        if (document.get("currentTrackImage") != nil) {
                            let userID = document.documentID
                            
                            dbRef.document(Auth.auth().currentUser!.uid).getDocument { (snapshot2, error2) in
                                if let document2 = snapshot2 {
                                    let matchesArray = document2.get("matches") as! Array<String>
                                    
                                    if matchesArray.contains(userID) == false {
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
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    // transitions the user to their profile screen
    @IBAction func toProfileButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: .main)

        if let profileViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = profileViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // transitions the user to their matches screen
    @IBAction func toMatchesButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Matches", bundle: .main)

        if let matchesViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = matchesViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // logs out the user and transitions them back to the login screen
    @IBAction func toLogoutButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: .main)

        if let loginViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = loginViewController
            view.window?.makeKeyAndVisible()
        }
    }
}

// handles the formatting of the annotation popups that are displayed when the user clicks on another user's pinned location
// each annotation displays the image, title name, and artist name of the pinned user's currently/ most recently played track; it also includes the option to play a thirty second snippet of said track as well as "like" the user's choice of track for potential matching
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
            // formats annotation popup display
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
                // begins playing track snippet
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
                // stops playing track snippet
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
            let likeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 35, height: 30)))
            likeButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = UIColor.systemPink
            view.rightCalloutAccessoryView = likeButton
            
            let db = Firestore.firestore()
            
            // check if other user (user b) has also liked current user's (user a) tracks
            let userA = (Auth.auth().currentUser?.uid)!
            let userB = annotation.userID!
            db.collection("users").document(userB).getDocument { (snapshot, error) in
                if let document = snapshot {
                    let likesArray = document.get("likes") as! Array<String>
                    let matchesArray = document.get("matches") as! Array<String>
                    
                    if likesArray.contains(userA) {
                        // if user a and user b like eachother's tracks, then they are matched together and user a is notified
                        db.collection("users").document(userA).updateData(["matches": FieldValue.arrayUnion(["\(String(describing: userB))"])])
                        db.collection("users").document(userB).updateData(["matches": FieldValue.arrayUnion(["\(String(describing: userA))"])])
                        db.collection("users").document(userB).updateData(["likes": FieldValue.arrayRemove(["\(String(describing: userA))"])])
                        
                        self.present(self.showAlert(Title: "It's a match!", Message: "You like eachother's music."), animated: true, completion: nil)
                    } else if matchesArray.contains(userA) == false {
                        // if not and the users aren't already matched to eachother, then user b is added to user a's list of liked users
                        db.collection("users").document(userA).updateData(["likes": FieldValue.arrayUnion(["\(String(describing: userB))"])])
                    }
                }
            }
        }
    }
}
