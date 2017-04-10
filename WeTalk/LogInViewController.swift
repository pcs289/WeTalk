//
//  LogInViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 20/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    var handle: FIRAuthStateDidChangeListenerHandle?

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func didForgotPassword(sender: AnyObject) {
        
        
        if email.text! != ""{
            FIRAuth.auth()?.sendPasswordResetWithEmail(email.text!, completion: { (error: NSError?) in
                print(error?.localizedDescription)
                if error == nil{
                    let alert = UIAlertController(title: "Link de reset enviado!", message: "Revisa tu email y haz click en el link para resetear tu contraseña", preferredStyle:.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            })
        }else{
            let alert = UIAlertController(title: "Error", message: "Introduce el email asociado a tu cuenta", preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didLogIn(sender: AnyObject) {
        if email.text! != "" && password.text != "" && password.text!.characters.count >= 6{
            FIRAuth.auth()?.signInWithEmail(email.text!, password: password.text!, completion: { (user: FIRUser?, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                User.userId = user!.uid
                self.performSegueWithIdentifier("loginToMain", sender: self)
            })
        }
        
        if password.text!.characters.count < 6{
            let alert = UIAlertController(title: "Error", message: "La contraseña debe tener al menos 6 caracteres", preferredStyle:.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Destructive, handler: { (action: UIAlertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: -50, width: 30, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        
        //self.navigationController?.navigationBar.topItem?.title = "Log In"
        
        
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
