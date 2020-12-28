//
//  UserData.swift
//  FireStoreDemo
//
//  Created by Gokul on 26/05/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import Foundation
class UserData {
    
    static let shared = UserData()
    
    var userName: String?
    
    private init() {
        
    }
}
