//
//  ProfileViewController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 28/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var ref = FIRDatabase.database().reference()
    var storage = FIRStorage.storage().reference()
    var userId: String = User.userId
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBAction func openCameraButton(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func checkMaxLength(sender: AnyObject) {
        self.checkMaxLength(input, maxLength: 15)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        profileImage.image = image

        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.updateProfilePicture(image)
    }
    
    func updateProfilePicture(image: UIImage){
        
        
        // upload Thumbnail

        var dataThumb = NSData()
        let thumbImage = resizeImage(image)
        dataThumb = UIImageJPEGRepresentation(thumbImage, 0.8)!
        
        let filePathThumb = "\(userId)/\("userThumb")"
        let metaDataThumb = FIRStorageMetadata()
        metaDataThumb.contentType = "image/jpg"
        self.storage.child(filePathThumb).putData(dataThumb, metadata: metaDataThumb){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //Store download link for this profile pic
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.ref.child("users").child(self.userId).updateChildValues(["userThumb": downloadURL])
            }
            
        }
        
        // upload Profile picture
        var data = NSData()
        data = UIImageJPEGRepresentation(image, 1)!
        let filePath = "\(userId)/\("userPhoto")"
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpg"
        self.storage.child(filePath).putData(data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                //Store download link for this profile pic
                let downloadURL = metaData!.downloadURL()!.absoluteString
                self.ref.child("users").child(self.userId).updateChildValues(["userPhoto": downloadURL])
            }
            
        }

        
    }
    
    func resizeImage(image:UIImage) -> UIImage
    {
        var actualHeight:Float = Float(image.size.height)
        var actualWidth:Float = Float(image.size.width)
        
        let maxHeight:Float = 70 //choose height
        let maxWidth:Float = 70  //choose width
        
        var imgRatio:Float = actualWidth/actualHeight
        let maxRatio:Float = maxWidth/maxHeight
        
        if (actualHeight > maxHeight) || (actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect:CGRect = CGRectMake(0.0, 0.0, CGFloat(actualWidth) , CGFloat(actualHeight) )
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        
        let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        let imageData:NSData = UIImageJPEGRepresentation(img, 1.0)!
        UIGraphicsEndImageContext()
        
        return UIImage(data: imageData)!
    }
    
    
    func getProfilePicture(){
        
        self.ref.child("users").child(userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            // check if user has photo
            
            
            
            if snapshot.hasChild("userPhoto"){
                // set image locatin
                let filePath = "\(self.userId)/\("userPhoto")"
                // Assuming a < 2MB file, though you can change that
                self.storage.child(filePath).dataWithMaxSize(1*1024*1024, completion: { (data, error) in
                    
                    let userPhoto = UIImage(data: data!)
                    self.profileImage.image = userPhoto
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        input.delegate = self
        
        profileImage.image = UIImage(named: "profile")
        profileImage.reloadInputViews()
        
        getProfilePicture()
        
        self.ref.child("users").child(userId).child("displayName").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
            self.name.text = snapshot.value! as? String
        })
        
        self.ref.child("users").child(userId).child("email").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
            self.email.text = snapshot.value! as? String
        })
        
        self.ref.child("users").child(userId).child("fullName").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
            self.input.text = snapshot.value! as? String
        })
        
        self.ref.child("users").child(userId).child("points").observeSingleEventOfType(.Value, withBlock: { (snapshot: FIRDataSnapshot) in
            
            if snapshot.exists(){
                let points = snapshot.value! as! Int
                self.points.text = "\(points) puntos acumulados"
            }
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        
        if textField.text!.characters.count > maxLength {
            textField.deleteBackward()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.ref.child("users").child(userId).child("fullName").setValue(textField.text)
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
