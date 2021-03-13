//
//  MatchesViewController.swift
//  groov
//
//  Created by Alice Wu on 2/18/21.
//

import UIKit

class MatchesViewController: UIViewController {

    // MARK: - Subviews
    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toSearchButton: UIButton!
    @IBOutlet weak var toLogoutButton: UIButton!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        self.toLogoutButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        super.viewDidLoad()
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
    
    // transitions the user to the search screen
    @IBAction func toSearchButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)

        if let searchViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = searchViewController
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
