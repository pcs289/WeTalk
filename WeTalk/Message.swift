//
//  Message.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 22/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message{
    var text: String!
    var senderId: String!
    var ref: FIRDatabaseReference
    var key: String
    
    init(snapshot: FIRDataSnapshot){
        self.text = snapshot.value!["text"] as! String
        self.senderId = snapshot.value!["senderId"] as! String
        self.ref = snapshot.ref
        self.key = snapshot.key
    }
}
