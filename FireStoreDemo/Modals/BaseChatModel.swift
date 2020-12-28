//
//  BaseChatModel.swift
//  FireStoreDemo
//
//  Created by Gokul on 12/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import Firebase

class BaseChatModel {
    
    var date: Timestamp
    var senderId: String
    var message: String
    
    init(date: Timestamp, id: String, message: String?) {
        self.date = date
        self.senderId = id
        self.message = message ?? ""
    }
}
