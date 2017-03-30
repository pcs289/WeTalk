//
//  ChatsPoolController.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 24/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit
import Firebase

class ChatsPoolController: NSObject {
    
    var ref = FIRDatabase.database().reference().child("/chats")
    
    func addNewChat(createdById: String, otherPersonId: String) -> String{
        
        let nR = ref.childByAutoId()
        nR.setValue(["details":["createdAt": NSDate(), "createdBy": createdById], "members":[createdById, otherPersonId]])
        let a = ref.queryOrderedByKey().queryLimitedToFirst(1).description
        print(a)
        
        return a
    }

}
