//
//  ListingViewController.swift
//  FireStoreDemo
//
//  Created by Gokul on 02/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import Firebase

class ListingViewController: BaseViewController {
    
    private let db = Firestore.firestore()
    var databaseListener: ListenerRegistration?
    
    let tableView = UITableView()
    var activityIndicator: UIActivityIndicatorView?
    var friendsList: [Friend] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "All Users"
        getUsersList()
        setUpTableView()
        addActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    private func addActivityIndicator() {
        let activityIV = Utility.activityIndicatorView(self)
        activityIndicator = activityIV
    }
    
    private func getUsersList() {
        guard let userId = UserDefaults.standard.value(forKey: BaseViewController.userIdKey) as? String else { return }
        let reference = db.collection("users")
        reference.getDocuments { (response, error) in
            if let documents = response?.documents, error == nil {
                var friendsList: [Friend] = []
                for document in documents {
                    let dictionary = document.data()
                    if (dictionary["userId"] as? String) != userId {
                        friendsList.append(Friend(userId: dictionary["userId"] as? String, name: dictionary["name"] as? String, profileImage: dictionary["profileImage"] as? String, publicKey: dictionary["publicKey"] as? Data))
                    }
                }
                self.friendsList = friendsList
            } else {
                print("something went wrong")
            }
            self.activityIndicator?.stopAnimating()
        }
    }
    
    private func setUpTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.edgesToSuperview()
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 83, bottom: 0, right: 9);
        tableView.register(NewFriendTableViewCell.self, forCellReuseIdentifier: NewFriendTableViewCell.cellIdentifier)
    }
    
    private func openChatViewController(threadDocumentId: String, friendId: String, publicKey: Data) {
        let chatVC = ChatViewController()
        chatVC.chatThreadId = threadDocumentId
        chatVC.friendId = friendId
        chatVC.publicKey = publicKey
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }

}

extension ListingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewFriendTableViewCell.cellIdentifier, for: indexPath) as? NewFriendTableViewCell else { return UITableViewCell()}
        cell.nameLabel.text = friendsList[indexPath.item].name
        if let imageURL = friendsList[indexPath.item].profileImage {
            cell.dpImageView.imageFrom(url: URL(string: imageURL)!)
        } else {
            cell.dpImageView.image = UIImage(named: "test")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        
        guard index < friendsList.count, let userId = UserDefaults.standard.value(forKey: BaseViewController.userIdKey) as? String, let userName = UserDefaults.standard.value(forKey: BaseViewController.userName) as? String else { return }
        
        let senderReference = db.collection("users").document(userId).collection("friends").document(friendsList[index].userId ?? "")
        let receiverReference = db.collection("users").document(friendsList[index].userId ?? "").collection("friends").document(userId)
        let chatThreadId: String = String((userId + (self.friendsList[index].userId ?? "")).sorted())
        
        
        makeFriendDocument(documentReference: senderReference, name: friendsList[index].name ?? "", userId: friendsList[index].userId ?? "", chatThreadId: chatThreadId, imageURL: friendsList[index].profileImage, publicKey: friendsList[index].publicKey) //Making friend document in own friends collection
        makeFriendDocument(documentReference: receiverReference, name: userName, userId: userId, chatThreadId: chatThreadId, imageURL: UserDefaults.standard.value(forKey: BaseViewController.profileImageURL) as? String, publicKey: UserDefaults.standard.value(forKey: BaseViewController.publicKey) as? Data) //Making friend document in receiver friends collection
        
        self.openChatViewController(threadDocumentId: chatThreadId, friendId: self.friendsList[index].userId ?? "", publicKey: self.friendsList[index].publicKey ?? Data())
    }
    
    private func makeFriendDocument(documentReference: DocumentReference, name: String, userId: String, chatThreadId: String, imageURL: String?, publicKey: Data?) {
        documentReference.setData([
            "name": name,
            "userId": userId,
            "profileImage": imageURL,
            "chatThreadId": chatThreadId,
            "publicKey": publicKey
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            }
        }
    }
}
extension UIActivityIndicatorView {

    convenience init(activityIndicatorStyle: UIActivityIndicatorView.Style, color: UIColor, placeInTheCenterOf parentView: UIView) {
        self.init(style: activityIndicatorStyle)
        center = parentView.center
        self.color = color
        parentView.addSubview(self)
    }
}
