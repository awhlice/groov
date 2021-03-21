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
    
    var index: Int!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        testLabel.text = ("Index \(index)")
        super.viewDidLoad()
    }
}
