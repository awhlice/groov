//
//  MessagingViewController.swift
//  groov
//
//  Created by Alice Wu on 3/21/21.
//

import UIKit
import Firebase

class MessagingViewController: UIViewController {
    
    // MARK: - Subviews
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var db: Firestore!
    var index: Int!
    var chatID: String!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                let match = matchesArray[self.index]
                
                self.chatID = self.getChatID(userA: Auth.auth().currentUser!.uid, userB: match)
                print("\(self.chatID)")
                
                self.db.collection("users").document(match).getDocument { (snapshot2, error) in
                    self.nameLabel.text = snapshot2!.get("firstName") as! String
                    self.nameLabel.alpha = 1
                }
            }
        }
        
        super.viewDidLoad()
    }
    
    // gets the chat ID between two users
    private func getChatID(userA: String, userB: String) -> String {
        if userA > userB {
            return userA
        }
        return userB
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toMatches", sender: self)
    }
}
