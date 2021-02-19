//
//  MatchesViewController.swift
//  groov
//
//  Created by Alice Wu on 2/18/21.
//

import UIKit

class MatchesViewController: UIViewController {

    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toSearchButton: UIButton!
    @IBOutlet weak var toSettingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func toProfileButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Profile", bundle: .main)

        if let profileViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = profileViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    @IBAction func toSearchButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)

        if let searchViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = searchViewController
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
