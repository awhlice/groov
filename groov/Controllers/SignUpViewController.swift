//
//  SignUpViewController.swift
//  groov
//
//  Created by Alice Wu on 2/11/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK: - Subviews
    // @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var connectSpotifyButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nevermindButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    func validateFields() -> String? {
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        let cleanedPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters, contains a special character, and a number."
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: .main)

        if let homeViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - IBActions
    // @IBAction func uploadPhotoButtonTapped(_ sender: Any) {
    // }
    
    @IBAction func connectSpotifyButtonTapped(_ sender: Any) {
    }
    
    @IBAction func nevermindButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        }
        else {
            let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                if err != nil {
                    self.showError("Error creating user.")
                }
                else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["firstname": firstName, "lastname": lastName, "email": email, "password": password, "uid": result!.user.uid ]) { (error) in
                        if error != nil {
                            self.showError("Error saving user data.")
                        }
                    }
                    
                    self.transitionToHome()
                }
            }
        }
    }
}
