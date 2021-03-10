//
//  ProfileViewController.swift
//  groov
//
//  Created by Alice Wu on 2/18/21.
//

import UIKit
import AVFoundation
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var currentTrackImageView: UIImageView!
    @IBOutlet weak var currentTrackButton: UIButton!
    @IBOutlet weak var currentTitleLabel: UILabel!
    @IBOutlet weak var currentArtistLabel: UILabel!
    @IBOutlet weak var firstTrackImageView: UIImageView!
    @IBOutlet weak var firstTrackButton: UIButton!
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstArtistLabel: UILabel!
    @IBOutlet weak var secondTrackImageView: UIImageView!
    @IBOutlet weak var secondTrackButton: UIButton!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondArtistLabel: UILabel!
    @IBOutlet weak var thirdTrackImageView: UIImageView!
    @IBOutlet weak var thirdTrackButton: UIButton!
    @IBOutlet weak var thirdTitleLabel: UILabel!
    @IBOutlet weak var thirdArtistLabel: UILabel!
    @IBOutlet weak var fourthTrackImageView: UIImageView!
    @IBOutlet weak var fourthTrackButton: UIButton!
    @IBOutlet weak var fourthTitleLabel: UILabel!
    @IBOutlet weak var fourthArtistLabel: UILabel!
    @IBOutlet weak var fifthTrackImageView: UIImageView!
    @IBOutlet weak var fifthTrackButton: UIButton!
    @IBOutlet weak var fifthTitleLabel: UILabel!
    @IBOutlet weak var fifthArtistLabel: UILabel!
    @IBOutlet weak var toSearchButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toSettingsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    override func viewDidLoad() {
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 970)
        
        self.currentTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        self.firstTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        self.secondTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        self.thirdTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        self.fourthTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        self.fifthTrackButton.layer.cornerRadius = 0.5 * self.currentTrackButton.bounds.size.width
        
        populateInfo()
        
        player = AVPlayer(playerItem: playerItem)
        
        super.viewDidLoad()
    }
    
    func populateInfo() {
        let db = Firestore.firestore()
        
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).getDocument { (snapshot, error) in
                if let document = snapshot {
                    if (document.get("currentTrackImage") != nil) {
                        let trackImage = document.get("currentTrackImage") as! String
                        let trackImageURL = NSURL(string: trackImage)
                        let trackData = NSData(contentsOf:trackImageURL! as URL)
                        if trackData != nil {
                            self.currentTrackImageView.image = UIImage(data:trackData! as Data)
                        }
                        let trackTitle = document.get("currentTrackName") as! String
                        self.currentTitleLabel.text = trackTitle
                        let trackArtist = document.get("currentTrackArtist") as! String
                        self.currentArtistLabel.text = trackArtist
                    }
                }
            }
            db.collection("users").document(uid).collection("tracks").document("rankedTrack1").getDocument { (snapshot, error) in
                if let document = snapshot {
                    let trackImage = document.get("trackImage") as! String
                    let trackImageURL = NSURL(string: trackImage)
                    let trackData = NSData(contentsOf:trackImageURL! as URL)
                    if trackData != nil {
                        self.firstTrackImageView.image = UIImage(data:trackData! as Data)
                    }
                    let trackTitle = document.get("trackName") as! String
                    self.firstTitleLabel.text = trackTitle
                    let trackArtist = document.get("trackArtist") as! String
                    self.firstArtistLabel.text = trackArtist
                }
            }
            db.collection("users").document(uid).collection("tracks").document("rankedTrack2").getDocument { (snapshot, error) in
                if let document = snapshot {
                    let trackImage = document.get("trackImage") as! String
                    let trackImageURL = NSURL(string: trackImage)
                    let trackData = NSData(contentsOf:trackImageURL! as URL)
                    if trackData != nil {
                        self.secondTrackImageView.image = UIImage(data:trackData! as Data)
                    }
                    let trackTitle = document.get("trackName") as! String
                    self.secondTitleLabel.text = trackTitle
                    let trackArtist = document.get("trackArtist") as! String
                    self.secondArtistLabel.text = trackArtist
                }
            }
            db.collection("users").document(uid).collection("tracks").document("rankedTrack3").getDocument { (snapshot, error) in
                if let document = snapshot {
                    let trackImage = document.get("trackImage") as! String
                    let trackImageURL = NSURL(string: trackImage)
                    let trackData = NSData(contentsOf:trackImageURL! as URL)
                    if trackData != nil {
                        self.thirdTrackImageView.image = UIImage(data:trackData! as Data)
                    }
                    let trackTitle = document.get("trackName") as! String
                    self.thirdTitleLabel.text = trackTitle
                    let trackArtist = document.get("trackArtist") as! String
                    self.thirdArtistLabel.text = trackArtist
                }
            }
            db.collection("users").document(uid).collection("tracks").document("rankedTrack4").getDocument { (snapshot, error) in
                if let document = snapshot {
                    let trackImage = document.get("trackImage") as! String
                    let trackImageURL = NSURL(string: trackImage)
                    let trackData = NSData(contentsOf:trackImageURL! as URL)
                    if trackData != nil {
                        self.fourthTrackImageView.image = UIImage(data:trackData! as Data)
                    }
                    let trackTitle = document.get("trackName") as! String
                    self.fourthTitleLabel.text = trackTitle
                    let trackArtist = document.get("trackArtist") as! String
                    self.fourthArtistLabel.text = trackArtist
                }
            }
            db.collection("users").document(uid).collection("tracks").document("rankedTrack5").getDocument { (snapshot, error) in
                if let document = snapshot {
                    let trackImage = document.get("trackImage") as! String
                    let trackImageURL = NSURL(string: trackImage)
                    let trackData = NSData(contentsOf:trackImageURL! as URL)
                    if trackData != nil {
                        self.fifthTrackImageView.image = UIImage(data:trackData! as Data)
                    }
                    let trackTitle = document.get("trackName") as! String
                    self.fifthTitleLabel.text = trackTitle
                    let trackArtist = document.get("trackArtist") as! String
                    self.fifthArtistLabel.text = trackArtist
                }
            }
            db.collection("users").document(uid).getDocument { (snapshot, error) in
                if let document = snapshot {
                    let image = document.get("image") as! String
                    let url = NSURL(string: image)
                    let data = NSData(contentsOf:url! as URL)
                    if data != nil {
                        self.profileImageView.image = UIImage(data:data! as Data)
                        self.profileImageView.alpha = 1
                    } else {
                        self.profileImageView.alpha = 1
                    }
                    let firstName = document.get("firstName") as! String
                    let lastName = document.get("lastName") as! String
                    self.nameLabel.alpha = 1
                    self.nameLabel.text = "\(firstName) \(lastName)"
                }
            }
        } else {
            print("Document does not exist")
        }
    }
    
    @IBAction func currentTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0  {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).getDocument { (snapshot, error) in
                    if let document = snapshot {
                        if (document.get("currentTrackPreview") != nil) {
                            let trackPreview = document.get("currentTrackPreview") as! String
                            let trackPreviewURL = URL(string: trackPreview)
                            let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                            self.player = AVPlayer(playerItem: playerItem)
                            self.player?.play()
                            self.currentTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                            }
                    }
                }
            }
       } else {
            self.player?.pause()
            self.currentTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func firstTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0 {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).collection("tracks").document("rankedTrack1").getDocument { (snapshot, error) in
                    if let document = snapshot {
                        let trackPreview = document.get("trackPreview") as! String
                        let trackPreviewURL = URL(string: trackPreview)
                        let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.firstTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                    }
                }
            }
       } else {
            self.player?.pause()
            self.firstTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func secondTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0 {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).collection("tracks").document("rankedTrack2").getDocument { (snapshot, error) in
                    if let document = snapshot {
                        let trackPreview = document.get("trackPreview") as! String
                        let trackPreviewURL = URL(string: trackPreview)
                        let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.secondTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                    }
                }
            }
       } else {
            self.player?.pause()
            self.secondTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func thirdTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0 {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).collection("tracks").document("rankedTrack3").getDocument { (snapshot, error) in
                    if let document = snapshot {
                        let trackPreview = document.get("trackPreview") as! String
                        let trackPreviewURL = URL(string: trackPreview)
                        let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.thirdTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                    }
                }
            }
       } else {
            self.player?.pause()
            self.thirdTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func fourthTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0 {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).collection("tracks").document("rankedTrack4").getDocument { (snapshot, error) in
                    if let document = snapshot {
                        let trackPreview = document.get("trackPreview") as! String
                        let trackPreviewURL = URL(string: trackPreview)
                        let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.fourthTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                    }
                }
            }
       } else {
            self.player?.pause()
            self.fourthTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func fifthTrackButtonTapped(_ sender: Any) {
        if self.player?.rate == 0 {
            let db = Firestore.firestore()
            
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("users").document(uid).collection("tracks").document("rankedTrack5").getDocument { (snapshot, error) in
                    if let document = snapshot {
                        let trackPreview = document.get("trackPreview") as! String
                        let trackPreviewURL = URL(string: trackPreview)
                        let playerItem: AVPlayerItem = AVPlayerItem(url: trackPreviewURL!)
                        self.player = AVPlayer(playerItem: playerItem)
                        self.player?.play()
                        self.fifthTrackButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                    }
                }
            }
       } else {
            self.player?.pause()
            self.fifthTrackButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
       }
    }
    
    @IBAction func toSearchButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)

        if let searchViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = searchViewController
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
