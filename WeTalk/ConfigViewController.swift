//
//  ConfigViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 22/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConfigViewCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var arrow: UIImageView!
}

class ConfigViewController: UITableViewController {
    var handle:FIRAuthStateDidChangeListenerHandle?
    var list = ["Ayuda", "Perfil", "Notificaciones", "FAQ", "Sobre nosotros", "Donaciones", "Cerrar sesión"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.navigationItem.title = "Configuración"
    }
    
    override func viewWillAppear(animated: Bool) {
        handle = FIRAuth.auth()?.addAuthStateDidChangeListener(){(user, error) in
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        FIRAuth.auth()?.removeAuthStateDidChangeListener(handle!)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
 
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("configCell", forIndexPath: indexPath) as! ConfigViewCell
        
        // Configure the cell...
        cell.name.text = list[indexPath.row]
        
    
        
        if indexPath.row == self.list.count-1{
            cell.backgroundColor = UIColor.blueColor()
            cell.name.textColor = UIColor.whiteColor()
            cell.name.textAlignment = .Center
            cell.arrow.hidden = true
        }
    
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 1:
            self.performSegueWithIdentifier("configToProfile", sender:nil)
        case 6:
            doLogout()
        default:
            print(list[indexPath.row])
        }
    }
    
    func doLogout(){
        
        do{
            try FIRAuth.auth()?.signOut()
        }catch{}
        
        if (User.alreadyLoggedIn == true){
            User.reset()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialVC = storyboard.instantiateViewControllerWithIdentifier("initialVC")
            self.presentViewController(initialVC, animated: true, completion: nil)
            
        }else{
            User.reset()
            self.performSegueWithIdentifier("unwindToStart", sender: self)
        }
        
        

        
    }
    
}
