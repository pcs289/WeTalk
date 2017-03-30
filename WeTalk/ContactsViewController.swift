//
//  ContactsViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 25/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import Firebase

class ContactsViewController: UITableViewController, UISearchResultsUpdating{
    
    let ref = FIRDatabase.database().reference()
    let userId = User.userId
    var newChatId = ""
    var contacts = [NSDictionary]()
    
    var contactsHandle: FIRDatabaseHandle?
    
    let searchController = UISearchController(searchResultsController: nil)
    var filterNames = [NSDictionary]()
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
      
        self.ref.child("users").queryOrderedByChild("displayName").queryEqualToValue(searchText.lowercaseString).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            if snapshot.exists(){
                let dic = snapshot.value! as! NSDictionary
                let disp = dic.allValues[0]["displayName"] as! String
                self.filterNames.append(["displayName": disp, "contactId": dic.allKeys[0]])
                self.tableView.reloadData()
            }
        }
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.ref.child("users/\(User.userId)/contacts").removeObserverWithHandle(contactsHandle!)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Contactos"
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Añadir contacto por nombre de usuario"
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
        contactsHandle = ref.child("users/\(User.userId)/contacts").observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
            if snapshot.value != nil{
                    self.ref.child("users").child(snapshot.key).queryOrderedByKey().queryEqualToValue("displayName").observeSingleEventOfType(.Value, withBlock: { (snap: FIRDataSnapshot) in
                        
                            print(snap)
                        
                            self.contacts.append(["displayName": snap.value!["displayName"] as! String, "contactId": snapshot.key])
                        
                        
                            self.tableView.reloadData()
                    })
                }
            }
    
    }

    func startChat(destinationId: String){
        
        self.ref.child("users/\(self.userId)/contacts").updateChildValues([destinationId: true])
        
        
        self.ref.child("users/\(self.userId)/chats").queryOrderedByKey().queryEqualToValue(destinationId).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            
            
            if !snapshot.exists(){
                
                let now = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .MediumStyle)
                
                let values:NSDictionary = ["details":["createdAt":now,"createdBy":self.userId] as NSDictionary,"members":[self.userId, destinationId] as Array<String>]
                
                let newThreadRef = self.ref.child("chats").childByAutoId()
                newThreadRef.setValue(values)
                
                let nTRef = newThreadRef.description().substringWithRange(Range<String.Index>(start: newThreadRef.description().startIndex.advancedBy(42), end: newThreadRef.description().endIndex))
                self.newChatId = nTRef
                
                self.ref.child("newThreads").child(destinationId).updateChildValues([nTRef : self.userId])
                
                self.ref.child("users").child(self.userId).child("chats").updateChildValues([destinationId: nTRef])
                
            }else{
                
                //print("already exists chat with this user")
                
                self.newChatId = snapshot.value![destinationId] as! String
                
            }
            
             self.performSegueWithIdentifier("chatSegue", sender: destinationId)
        }
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filterNames.count
        }
        return self.contacts.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if searchController.active && searchController.searchBar.text != "" {
            if self.filterNames[indexPath.row]["contactId"] as! String != User.userId{
                startChat(self.filterNames[indexPath.row]["contactId"] as! String)
            }else{
                print("Cannot start chat with myself")
            }
        } else {
            startChat(self.contacts[indexPath.row]["contactId"] as! String)
        }

       
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("contactsCell", forIndexPath: indexPath)
        var text = ""
        if searchController.active && searchController.searchBar.text != "" {
            text = filterNames[indexPath.row]["displayName"] as! String
        } else {
            text = self.contacts[indexPath.row]["displayName"] as! String
        }
        cell.textLabel?.text = text
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatSegue"{
            let vc: ChatViewController = segue.destinationViewController as! ChatViewController
            vc.otherUserId = sender as! String
            vc.chatId = newChatId
        }
    }

}
