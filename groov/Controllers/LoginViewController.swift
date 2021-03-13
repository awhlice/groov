//
//  LoginViewController.swift
//  groov
//
//  Created by Alice Wu on 2/8/21.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK: - Subviews
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // transitions the user to the search screen
    func transitionToSearch() {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)

        if let searchViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = searchViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - IBActions
    
    // logs the user in if they enter the correct login info
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                self.errorLabel.text = "Incorrect email or password."
                self.errorLabel.alpha = 1
            }
            else {
                self.transitionToSearch()
            }
        }
    }
    
    // transitions the user to the signup screen
    @IBAction func signUpButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignUp", sender: self)
    }
}
