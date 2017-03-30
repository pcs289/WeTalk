//
//  SignUpViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 20/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    var handle : FIRAuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func didTouchRegister(sender: AnyObject) {
        
        if email.text != "" && password.text != "" && password.text?.characters.count >= 6{
            
            FIRAuth.auth()?.createUserWithEmail(email.text!, password: password.text!, completion: { (user :FIRUser?, error) in
                
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                
                User.userId = user!.uid
                print(User.userId)
                
                let ref = FIRDatabase.database().referenceFromURL("https://wetalk-8200d.firebaseio.com/users/\(user!.uid)")
                
                var values = ["email":self.email.text!, "displayName":"", "fullName":""]
                
                if self.fullName.text != nil{
                    values.updateValue(self.fullName.text!, forKey: "fullName")
                }
                if self.username.text != nil{
                    values.updateValue(self.username.text!, forKey: "displayName")
                }
                
                ref.updateChildValues(values, withCompletionBlock: { (err, refe:FIRDatabaseReference) in
                    
                    if err != nil{
                        return
                    }
                    print("going to main!")
                    self.performSegueWithIdentifier("registerToMain", sender: nil)
                    
                })
                
            })
        }else{
            //Not email nor password length(>= 6)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: -50, width: 30, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        //self.navigationController?.navigationBar.topItem?.title = "Sign Up"
        
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        handle = FIRAuth.auth()?.addAuthStateDidChangeListener(){(user, error) in
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        FIRAuth.auth()?.removeAuthStateDidChangeListener(handle!)
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
