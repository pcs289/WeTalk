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

class ChatViewController: JSQMessagesViewController, UIAlertViewDelegate {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    var userId = User.userId
    var otherUserId: String = User.otherUserId
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var chatId = User.currentChatId
    
    var messageHandler: FIRDatabaseHandle?
    
    
    override func viewDidLoad() {
        
        self.senderId = userId
        self.senderDisplayName = User.displayName
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.inputToolbar.contentView.rightBarButtonItem.titleLabel?.text = "Enviar"

        self.inputToolbar.contentView.textView.placeHolder = "Nuevo mensaje"
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
        
        let wordsAr = text.characters.split{$0 == " "}.map(String.init)
        
        print(wordsAr)
        
        var wrongWords = [String]()
        
        
        for word in wordsAr{

            if !wordIsSpelledCorrect(word) || word.characters.count > 20{
               wrongWords.append(word)
                print(wrongWords.count)
            }
        }
        
        if wrongWords.count > 0{
            
            var message = "Hay varias palabras mal escritas"
            if wrongWords.count == 1{
                message = "'\(wrongWords.first!)' está mal escrito"
            }
            
            let alert = UIAlertController(title: "Error", message: message, preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: "vaya...", style: .Destructive, handler: { (action: UIAlertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }else{
            
            //Check for current user points
            self.ref.child("users").child(userId).child("points").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                
                if snapshot.exists(){
                    //Add previous points & update
                    let prevPoints = snapshot.value! as! Int
                    let updatedPoints = prevPoints + self.calculatePointsFromArray(wordsAr)
                    self.ref.child("users").child(self.userId).child("points").setValue(updatedPoints)
                    
                }else{
                    //Set value for your first points!
                    print("No points yet")
                    let points = self.calculatePointsFromArray(wordsAr)
                    
                    self.ref.child("users").child(self.userId).child("points").setValue(points)
                }
                
                //Send Message
                let messageValues: NSDictionary = ["content":text, "senderId": senderId, "senderDisplayName": senderDisplayName]
                self.ref.child("chats").child(self.chatId).child("messages").childByAutoId().setValue(messageValues)
                
                self.ref.child("chats").child(self.chatId).child("details").child("pendingRead").setValue(self.otherUserId)
                
                self.finishSendingMessage()
                
            })
            
            
        }
    }
    
    
    func calculatePointsFromArray(ar: [String]) -> Int{
        var p = 0
        for elem: String in ar{
            if elem.characters.count >= 5{
                p = p + 3
            }else{
                p = p + 1
            }
        }
        return p
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    
    func wordIsSpelledCorrect(word: String) -> Bool {
        
        if word.characters.count == 1{
            print("1 character")
            if word == "y" || word == "a" || word == "e" || word == "u"{
                return true
            }else{
                return false
            }
        }
        
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let wordRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "es_ES")
        
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
