//
//  ViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 20/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ViewController: UIViewController {

    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        User.alreadyCheckedRegisterCode = NSUserDefaults.standardUserDefaults().boolForKey("registerCode")
        
        if User.alreadyCheckedRegisterCode == false{
            self.checkRegisterCode()
        }
    }
    
    func checkRegisterCode(){
        
        
        let importantAlert: UIAlertController = UIAlertController(title: "Código de registro", message: "Inserta el código de registro", preferredStyle: .Alert)
        
        importantAlert.addTextFieldWithConfigurationHandler({ (textField: UITextField) in
            textField.placeholder = "Codigo de registro"
            textField.clearButtonMode = .WhileEditing
            textField.borderStyle = .RoundedRect
        })
        
        let checkAction = UIAlertAction(title: "Comprobar", style: .Default, handler: { (alert: UIAlertAction) in
            
            let textField = importantAlert.textFields![0]
            if textField.text != nil{
                
                FIRDatabase.database().reference().child("registerCode").queryOrderedByKey().queryEqualToValue(textField.text!).observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
                    
                    if snapshot.exists(){
                        
                        let dic = snapshot.value! as! NSDictionary
                       
                        if dic[textField.text!] as! Bool == false{
                            print("code not used")
                            NSUserDefaults.standardUserDefaults().setValue(textField.text!, forKey: "registerCodeValue")
                            NSUserDefaults.standardUserDefaults().setBool(true, forKey:"registerCode")
                            User.alreadyCheckedRegisterCode = NSUserDefaults.standardUserDefaults().boolForKey("registerCode")
                            FIRDatabase.database().reference().child("registerCode").child(textField.text!).setValue(true)
                        }
                        
                    }else{
                        
                        self.checkRegisterCode()
                    }
                })
            
            }
        })
        
        importantAlert.addAction(checkAction)
        
        self.presentViewController(importantAlert, animated: true, completion: nil)
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

