//
//  ProfileViewController.swift
//  groov
//
//  Created by Alice Wu on 2/18/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var toSearchButton: UIButton!
    @IBOutlet weak var toMatchesButton: UIButton!
    @IBOutlet weak var toSettingsButton: UIButton!
    
    override func viewDidLoad() {
        populateInfo()
        super.viewDidLoad()
    }
    
    func populateInfo() {
        let db = Firestore.firestore()
        
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).getDocument { (snapshot, error ) in
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
                } else {
                    print("Document does not exist")
                }
            }
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
