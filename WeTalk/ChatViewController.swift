//
//  ChatViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 22/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    var userId = User.userId
    var otherUserId: String = ""
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var chatId = ""
    
    var messageHandler: FIRDatabaseHandle?
    
    
    override func viewDidLoad() {
        
        self.senderId = userId
        self.senderDisplayName = User.displayName
        self.editButtonItem().title = "Enviar"
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if self.navigationController!.viewControllers.endIndex > 2{
            self.navigationController?.viewControllers.removeAtIndex(1)
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        
        self.ref.child("users").child(otherUserId).observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            self.navigationItem.title = snapshot.value!["displayName"] as? String
        }
        
        
       messageHandler =  self.ref.child("chats").child(chatId).child("messages").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            
            let sender = snapshot.value!["senderId"] as! String
            let dispName = snapshot.value!["senderDisplayName"] as! String
            let content = snapshot.value!["content"] as! String
            
            self.messages += [JSQMessage(senderId: sender, displayName: dispName, text: content)]
            self.collectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: User Input Methods
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if wordIsSpelledCorrect(text){
            let messageValues: NSDictionary = ["content":text, "senderId": senderId, "senderDisplayName": senderDisplayName]
            self.ref.child("chats").child(chatId).child("messages").childByAutoId().setValue(messageValues)
            self.finishSendingMessage()
        }else{
            print(text," misspelled")
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    
    func wordIsSpelledCorrect(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let wordRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "es")
        
        return wordRange.location == NSNotFound
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        self.ref.child("chats").child(chatId).child("messages").removeObserverWithHandle(messageHandler!)
    }
    
    //MARK: CollectionView Methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
