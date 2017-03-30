//
//  MainTableViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 21/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import Firebase


class customMainTableCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var username: UILabel!
    
    
}

class MainTableViewController: UITableViewController {
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    var currentUser: FIRUser?
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var storage = FIRStorage.storage().reference()
    var userId: String?
    
    var newThreadHandle: FIRDatabaseHandle?
    var chatsHandle: FIRDatabaseHandle?
    
    var conv = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let configButton = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action:  #selector(configTapped))
        
        self.navigationItem.rightBarButtonItem = configButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(selectContact))
        
        self.navigationItem.title = "Chats"
        
        userId = FIRAuth.auth()?.currentUser?.uid
        User.userId = userId!
        
        self.ref.child("users").child(userId!).observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            User.displayName = snapshot.value!.valueForKey("displayName")! as! String
            print("USERDISPLAYNAME: "+User.displayName)
        }
        
        
        //Check for my UID in a newThreads pool to add the new conversation ID to my own node of chats in case I didn't start the conversation
        newThreadHandle = self.ref.child("newThreads").child(userId!).observeEventType(.ChildAdded) { (snapshot: FIRDataSnapshot) in
    
            
            self.ref.child("users").child(self.userId!).child("chats").child(snapshot.value as! String).setValue(snapshot.key)
            self.ref.child("users").child(self.userId!).child("contacts").childByAutoId().setValue(snapshot.value as! String)
            
        }
        
        //Check for /newThreads on my own subnode to sync with client
        
        chatsHandle = self.ref.child("users").child(userId!).child("chats").observeEventType(.ChildAdded){ (snapshot: FIRDataSnapshot) in
            
            self.ref.child("newThreads").child(self.userId!).child(snapshot.value! as! String).removeValue()
           
            
            self.ref.child("users").queryOrderedByKey().queryEqualToValue(snapshot.key).queryLimitedToFirst(1)
                .observeSingleEventOfType(.Value, withBlock: { (snap: FIRDataSnapshot) in
                    
                    print("/users/\(snapshot.key)/chats: "+snapshot.description)
                let dic = snap.value! as! NSDictionary
                let dic2 = dic.allValues[0] as! NSDictionary
                    
                print(dic2)
                    
                self.conv.append(["displayName":dic2.valueForKey("displayName")! as! String, "chatId": snapshot.value! as! String, "otherUserId": snapshot.key])
                self.tableView.reloadData()
            })
            
        }
        
       
        
        
    }
    
    func configTapped(){
        self.performSegueWithIdentifier("configSegue", sender: self)
    }
    
    
    func selectContact(){
        self.performSegueWithIdentifier("selectContact", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        handle = FIRAuth.auth()?.addAuthStateDidChangeListener(){(user, error) in
            
            self.currentUser = FIRAuth.auth()?.currentUser
            self.userId = self.currentUser?.uid
            User.userId = self.userId!
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        FIRAuth.auth()?.removeAuthStateDidChangeListener(handle!)
        self.ref.child("users").child(userId!).child("chats").removeObserverWithHandle(chatsHandle!)
        self.ref.child("newThreads").child(userId!).removeObserverWithHandle(newThreadHandle!)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.conv.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! customMainTableCell
        
        cell.profileImage.clipsToBounds = true
        
        let otherUserId: String = self.conv[indexPath.row].valueForKey("otherUserId") as! String
        print(otherUserId)
        
        self.ref.child("users").child(otherUserId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.hasChild("userThumb"){
                // set image locatin
                let filePath = "\(otherUserId)/\("userThumb")"
                // Assuming a < 2MB file, though you can change that
                self.storage.child(filePath).dataWithMaxSize(1*1024*1024, completion: { (data, error) in
                    
                    let image = UIImage(data: data!)
                    cell.profileImage.image = image
                    
                })
            }
        })
        
        cell.username.text = self.conv[indexPath.row]["displayName"] as? String
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("chatSegue", sender: indexPath.row)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue){
        print("Logged Out")
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        if segue.identifier == "unwindToStart"{
            
            print("DestinationController")
            print(segue.destinationViewController)
            
        }
        
        if segue.identifier == "chatSegue"{
            let vc:ChatViewController = segue.destinationViewController as! ChatViewController
            vc.senderId = currentUser?.uid
            vc.senderDisplayName = User.displayName
            let chatId = self.conv[sender as! Int]["chatId"]! as! String
        
            self.ref.child("chats").child(chatId).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                print(snapshot.value! as! NSDictionary)
                let arr = snapshot.value as! NSDictionary
                for member in arr["members"] as! NSArray{
                    if member as! String != User.userId{
                        vc.otherUserId = member as! String
                        
                        vc.chatId = self.conv[sender as! Int]["chatId"] as! String
                        
                        vc.view.layoutIfNeeded()
                    }
                    
                    
                }
            })
            
        }
    }

}
