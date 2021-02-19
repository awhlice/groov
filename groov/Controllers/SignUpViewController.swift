//
//  SignUpViewController.swift
//  groov
//
//  Created by Alice Wu on 2/11/21.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    // MARK: - Subviews
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
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
        
        imagePicker.delegate = self
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            self.uploadImageButton.isEnabled = false
            self.uploadImageButton.isHidden = true
            self.imageView.image = pickedImage
            self.imagePicker.dismiss(animated: true, completion: nil)
        }
    }

    func showAlert(Title : String!, Message : String!)  -> UIAlertController {
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default)

        alertController.addAction(okAction)
        
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame

        return alertController
      }
    
    func validateFields() -> String? {
        if firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    func transitionToSearch() {
        let storyboard = UIStoryboard(name: "Search", bundle: .main)

        if let searchViewController = storyboard.instantiateInitialViewController() {
            view.window?.rootViewController = searchViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    // MARK: - IBActions
    @IBAction func uploadImageButtonTapped(_ sender: Any) {
        let alertController : UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction : UIAlertAction = UIAlertAction(title: "Take Photo", style: .default, handler: {(cameraAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.present(self.showAlert(Title: nil, Message: "Please allow access to your camera to take your profile photo."), animated: true, completion: nil)
            }
        })
        
        let libraryAction : UIAlertAction = UIAlertAction(title: "Choose from Library", style: .default, handler: {(libraryAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true {
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.present(self.showAlert(Title: nil, Message: "Please allow access to your photo library to select your profile image."), animated: true, completion: nil)
            }
        })
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)

        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame

        self.present(alertController, animated: true, completion: nil)
    }
    
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
                    
                    if self.imageView.image != nil {
                        let storageRef = Storage.storage().reference().child("user/\(String(describing: Auth.auth().currentUser?.uid))")
                        
                        let storedImage = storageRef.child("image/\(String(describing: Auth.auth().currentUser?.uid))")
                    
                        if let uploadData = self.imageView.image?.jpegData(compressionQuality: 1) {
                            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                                if error != nil {}
                                storedImage.downloadURL(completion: { (url, error) in
                                    if error != nil {}
                                    if let urlText = url?.absoluteString {
                                        db.collection("users").addDocument(data: ["firstName": firstName, "lastName": lastName, "email": email, "password": password, "image": urlText, "uid": result!.user.uid]) { (error) in
                                            if error != nil {
                                                self.showError("Error saving user data.")
                                            }
                                        }
                                    }
                                })
                            })
                        }
                    } else {
                        db.collection("users").addDocument(data: ["firstName": firstName, "lastName": lastName, "email": email, "password": password, "image": "", "uid": result!.user.uid]) { (error) in
                            if error != nil {
                                self.showError("Error saving user data.")
                            }
                        }
                    }
                    
                    self.transitionToSearch()
                }
            }
        }
    }
}
