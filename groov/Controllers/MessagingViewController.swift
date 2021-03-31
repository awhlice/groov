//
//  MessagingViewController.swift
//  groov
//
//  Created by Alice Wu on 3/21/21.
//

import UIKit
import MessageKit
import Firebase

class MessagingViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    // MARK: - Subviews
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subview: UIView!
    
    typealias completion = (_ isFinished:Bool) -> Void
    
    var db: Firestore!
    var index: Int!
    var chatId: String!
    var currentUser: Sender!
    var messages = [MessageType]()

    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        db = Firestore.firestore()
        
        // updates message display screen with relevant info
        self.getChatInfo(completionHandler: { (isFinished) in
            if isFinished {
                self.displayMessages(completionHandler: { (isFinished) in
                    if isFinished {
                        super.viewDidLoad()
                        self.view.addSubview(self.subview)
                        
                        self.messagesCollectionView.contentInset.top = 120
                        self.messagesCollectionView.messagesDataSource = self
                        self.messagesCollectionView.messagesLayoutDelegate = self
                        self.messagesCollectionView.messagesDisplayDelegate = self
                    }
                })
            }
        })
    }
    
    // returns the user that is currently sending messages
    func currentSender() -> SenderType {
        return currentUser!
    }
    
    // returns the appropriate message for each row
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    // returns the number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // gets the chat ID between two users and current user object, and displays the other user's name
    private func getChatInfo(completionHandler: @escaping completion) {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                let userA = Auth.auth().currentUser!.uid
                let userB = matchesArray[self.index]
                if userA > userB {
                    self.chatId = userA
                } else {
                    self.chatId = userB
                }
                let senderName = snapshot!.get("firstName") as! String
                self.currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: senderName)
                self.db.collection("users").document(userB).getDocument { (snapshot2, error) in
                    self.nameLabel.text = snapshot2!.get("firstName") as? String
                    self.nameLabel.alpha = 1
                }
            }
            completionHandler(true)
        }
    }
    
    // retrieves messages from database and displays them on screen
    private func displayMessages(completionHandler: @escaping completion) {
        let dbRef = db.collection("chats").document(chatId).collection("messages")
        dbRef.getDocuments { snapshot, error in
            if snapshot?.isEmpty == false {
                for document in snapshot!.documents {
                    let senderId = document.get("senderId") as! String
                    let senderName = document.get("senderName") as! String
                    let sender = Sender(senderId: senderId, displayName: senderName)
                    let messageId = document.get("messageId") as! String
                    let timestamp = document.get("sentDate") as! Timestamp
                    let sentDate = timestamp.dateValue()
                    let content = document.get("content") as! String
                    
                    self.messages.append(Message(sender: sender,
                                messageId: messageId,
                                sentDate: sentDate,
                                kind: .text(content)))
                }
            }
            completionHandler(true)
        }
    }
    
    // brings the user back to their matches screen
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toMatches", sender: self)
    }
}
