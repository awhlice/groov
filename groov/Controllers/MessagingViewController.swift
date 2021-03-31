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
    @IBOutlet weak var testLabel: UILabel!
    
    var db: Firestore!
    var index: Int!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                let match = matchesArray[self.index]
                
                self.testLabel.text = ("\(match)")
            }
        }
        super.viewDidLoad()
    }
}
