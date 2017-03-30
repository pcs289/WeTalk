//
//  User.swift
//  WeTalk
//
//  Created by Pau De La Cuesta Sala on 22/03/17.
//  Copyright © 2017 Pau De La Cuesta Sala. All rights reserved.
//

import UIKit

struct User {
    static var alreadyLoggedIn: Bool = false
    static var displayName: String = ""
    static var userId: String = ""
    
    static func reset(){
        alreadyLoggedIn = false
        displayName = ""
        userId = ""
    }
}