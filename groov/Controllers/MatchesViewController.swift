//
//  MatchesViewController.swift
//  groov
//
//  Created by Alice Wu on 2/18/21.
//

import UIKit
import Firebase

class MatchesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Subviews
    @IBOutlet weak var toProfileButton: UIButton!
    @IBOutlet weak var toSearchButton: UIButton!
    @IBOutlet weak var toLogoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var db: Firestore!
    var numCells: Int = 0
    
    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        self.toLogoutButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        db = Firestore.firestore()
        
        getNumCells()
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // gets the number of matches in the user's list of matches
    private func getNumCells() {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                self.numCells = matchesArray.count
                self.tableView.reloadData()
            } else {
                self.numCells = 0
            }
        }
    }
    
    // sets the height of the table view match cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(120)
    }
    
    // returns the number of matches in the user's list of matches
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCells
    }
    
    // formats the first name and profile image for each match in its table view match cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MatchCell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchCell
        
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                let match = matchesArray[indexPath.row]
                
                self.db.collection("users").document(match).getDocument { (snapshot2, error) in
                    let firstName = snapshot2!.get("firstName") as! String
                    let lastName = snapshot2!.get("lastName") as! String
                    cell.nameLabel.text = "\(firstName) \(lastName)"
                    cell.nameLabel.alpha = 1
                    let image = snapshot2!.get("image") as! String
                    let url = NSURL(string: image)
                    let data = NSData(contentsOf:url! as URL)
                    if data != nil {
                        cell.profileImageView.image = UIImage(data:data! as Data)
                        cell.profileImageView.alpha = 1
                    }
                }
            }
        }
        
        return cell
    }
    
    // passes on the tapped cell's index to the Messaging View Controller to know which match was selected for further messaging
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        let index = indexPath?.row
        print("\(String(describing: index))")
        let messagingViewController = segue.destination as! MessagingViewController
        messagingViewController.index = index
    }
    
    // transitions the user to the messaging screen for the specified match
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toMessaging", sender: self)
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
