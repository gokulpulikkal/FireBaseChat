//
//  HomeViewModel.swift
//  FireStoreDemo
//
//  Created by Gokul on 17/06/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import Foundation
import Firebase

class HomeViewModel {
    
    private let db = Firestore.firestore()
    var databaseListener: ListenerRegistration?
    var friendsList: Dynamic<[Friend]?>
    var modifiedChats: Dynamic<[String]?>
    var newFriendsList: Dynamic<[Friend]?>
    
    init() {
        self.friendsList = Dynamic(nil)
        self.newFriendsList = Dynamic(nil)
        self.modifiedChats = Dynamic([])
    }
    
    func getFriendsList(userId: String?) {
        guard let userId = userId else { return }
        let reference = db.collection("users").document(userId).collection("friends")
        reference.getDocuments { (response, error) in
            if let documents = response?.documents, error == nil {
                var friendsList: [Friend] = []
                for document in documents {
                    let dictionary = document.data()
                    friendsList.append(Friend(userId: dictionary["userId"] as? String, name: dictionary["name"] as? String, profileImage: dictionary["profileImage"] as? String, chatThreadId: dictionary["chatThreadId"] as? String))
                }
                self.friendsList.value = friendsList
                self.listenToFriendsCollection(userId: userId)
            } else {
                print("something went wrong")
            }
        }
    }
    
    private func listenToFriendsCollection(userId: String) {
        db.collection("users").document(userId).collection("friends").addSnapshotListener { documentSnapshots, error in
            
            guard let documentSnapshots = documentSnapshots else {
                print("Error fetching document: \(error!)")
                return
            }
            var chatThreadIds: [String] = []
            var newFriends: [Friend] = []
            documentSnapshots.documentChanges.forEach { diff in
                let documentData = diff.document.data()
                if (diff.type == .modified), let chatThreadId = documentData["chatThreadId"] as? String {
                    chatThreadIds.append(chatThreadId)
                    print("testing chat is modified")
                } else if diff.type == .added {
                    print("testing chat is added")
                    if let userId = documentData["userId"] as? String, !(self.friendsList.value?.contains(where: { $0.userId == userId }) ?? false) {
                        newFriends.append(Friend(userId: userId, name: documentData["name"] as? String, profileImage: documentData["profileImage"] as? String, chatThreadId: documentData["chatThreadId"] as? String))
                    }
                }
            }
            self.modifiedChats.value = chatThreadIds
            self.newFriendsList.value = newFriends
        }
    }
}

struct Friend: Codable {
    var userId: String?
    var name: String?
    var profileImage: String?
    var chatThreadId: String?
}
