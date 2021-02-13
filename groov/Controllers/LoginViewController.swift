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
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: .main)

        if let homeViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                self.errorLabel.text = "Incorrect email or password."
                self.errorLabel.alpha = 1
            }
            else {
                self.transitionToHome()
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toSignUp", sender: self)
    }
}
