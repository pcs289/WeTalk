//
//  ConfigViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 22/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConfigViewController: UITableViewController {
    var handle:FIRAuthStateDidChangeListenerHandle?
    var list = ["Ayuda", "Perfil", "Notificaciones", "FAQ", "Sobre nosotros", "Donaciones", "Cerrar sesión"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier("configCell", forIndexPath: indexPath)
        
        // Configure the cell...
        cell.textLabel?.text = list[indexPath.row]
        
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
