//
//  MessagingViewController.swift
//  groov
//
//  Created by Alice Wu on 3/21/21.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import SDWebImage

class MessagingViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    // MARK: - Subviews
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var unmatchButton: UIView!
    @IBOutlet weak var subview: UIView!
    
    typealias completion = (_ isFinished:Bool) -> Void
    
    var db: Firestore!
    var index: Int!
    var chatId: String!
    var currentUser: Sender!
    var otherUser: Sender!
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
                        self.messageInputBar.delegate = self
                    }
                })
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
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
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == Auth.auth().currentUser!.uid {
            SDWebImageManager.shared.loadImage(with: URL(string: currentUser.senderImage), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                avatarView.image = image }
        } else {
            SDWebImageManager.shared.loadImage(with: URL(string: otherUser.senderImage), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
            avatarView.image = image }
        }
    }
    
    // gets the other user object and displays the other user's name
    private func getOtherUser(otherUserId: String, completionHandler: @escaping completion) {
        db.collection("users").document(otherUserId).getDocument { (snapshot, error) in
            let otherName = snapshot!.get("firstName") as! String
            let otherImage = snapshot!.get("image") as! String
            self.otherUser = Sender(senderId: otherUserId, displayName: otherName, senderImage: otherImage)
            self.nameLabel.text = otherName
            self.nameLabel.alpha = 1
            completionHandler(true)
        }
    }
    
    // gets the chat ID between two users and the current user object, calls another function to get the other user object
    private func getChatInfo(completionHandler: @escaping completion) {
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (snapshot, error) in
            if snapshot!.exists == true {
                let matchesArray = snapshot!.get("matches") as! Array<String>
                let userA = Auth.auth().currentUser!.uid
                let userB = matchesArray[self.index]
                if userA > userB {
                    self.chatId = userA + userB
                } else {
                    self.chatId = userB + userA
                }
                let senderName = snapshot!.get("firstName") as! String
                let senderImage = snapshot!.get("image") as! String
                self.currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: senderName, senderImage: senderImage)
        
                self.getOtherUser(otherUserId: userB, completionHandler: { (isFinished) in
                    if isFinished {
                        completionHandler(true)
                    }
                })
            }
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
                    let senderImage = document.get("senderImage") as! String
                    let sender = Sender(senderId: senderId, displayName: senderName, senderImage: senderImage)
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
    
    // sends and displays message on the chat screen
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        let senderId = currentUser.senderId
        let senderName = currentUser.displayName
        let senderImage = currentUser.senderImage
        let messageId = String(self.messages.count)
        let sentDate = Date()
        let content = text
        
        // updates the conversation's collection of messages with the newly sent message
        self.db.collection("chats").document(chatId).collection("messages").document(messageId).setData(["content": text, "messageId": messageId, "senderId": senderId, "senderImage": senderImage, "senderName": senderName, "sentDate": sentDate])
        
        // displays the newly sent message on the chat screen
        self.messages.append(Message(sender: currentUser,
                    messageId: messageId,
                    sentDate: sentDate,
                    kind: .text(content)))
        
        // reloads the view after sending a message
        inputBar.inputTextView.text = ""
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    // MARK: - IBActions
    
    // brings the user back to their matches screen
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toMatches", sender: self)
    }
    
    // checks if the user would like to unmatch with their current match and unmatches them accordingly
    @IBAction func unmatchButtonTapped(_ sender: Any) {
        let unmatchAlert = UIAlertController(title: nil, message: "Are you sure you want to unmatch with this user?", preferredStyle: UIAlertController.Style.alert)

        unmatchAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            for i in 0...self.messages.count - 1 {
                self.db.collection("chats").document(self.chatId).collection("messages").document(String(i)).delete()
            }
            self.db.collection("chats").document(self.chatId).delete()
            self.db.collection("users").document(self.currentUser.senderId).updateData(["matches": FieldValue.arrayRemove(["\(String(describing: self.otherUser.senderId))"])])
            self.db.collection("users").document(self.otherUser.senderId).updateData(["matches": FieldValue.arrayRemove(["\(String(describing: self.currentUser.senderId))"])])
            self.performSegue(withIdentifier: "toMatches", sender: self)
        }))
        
        unmatchAlert.addAction(UIAlertAction(title: "No", style: .cancel))

        self.present(unmatchAlert, animated: true, completion: nil)
    }
}
