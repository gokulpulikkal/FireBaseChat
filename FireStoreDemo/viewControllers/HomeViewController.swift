//
//  HomeViewController.swift
//  FireStoreDemo
//
//  Created by Gokul on 26/05/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import TinyConstraints

class HomeViewController: BaseViewController {

    let viewModal: HomeViewModel = HomeViewModel()
    let tableView = UITableView()
    var userId: String?
    var activityIndicator: UIActivityIndicatorView?
    var tableViewDataList: [Friend] = []
    
    var navigationView: CustomNavigationBar = {
        let view = CustomNavigationBar(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var labelView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var newMessageUpdateIndexSet = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpTableView()
        listenToViewModel()
        addFloatingButton()
        setUserNameOnTop()
        activityIndicator = Utility.activityIndicatorView(self)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriendsList()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func getFriendsList() {
        if let userId = UserDefaults.standard.value(forKey: BaseViewController.userIdKey) as? String {
            viewModal.getFriendsList(userId: userId)
        } else {
            presentLoginViewController()
        }
    }
    
    private func setUserNameOnTop() {
        if let userName = UserDefaults.standard.value(forKey: BaseViewController.userName) as? String {
            self.view.addSubview(labelView)
            labelView.text = userName
            labelView.centerInSuperview()
        }
    }
    
    private func setUpNavigationBar() {
        self.view.addSubview(navigationView)
        navigationView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        navigationView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        navigationView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        navigationView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        navigationView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }
    
    private func setUpTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 83, bottom: 0, right: 9);
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.cellIdentifier)
    }
    private func addFloatingButton() {
        let buttonView = UIButton()
        buttonView.setImage(UIImage(named: "plus"), for: .normal)
        buttonView.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        buttonView.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        buttonView.imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(buttonView)
        buttonView.width(60)
        buttonView.height(60)
        buttonView.layer.cornerRadius = 30
        buttonView.backgroundColor = UIColor.getColor(R: 46, G: 116, B: 254)
        buttonView.layer.masksToBounds = false
        buttonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -35).isActive = true
        buttonView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -15).isActive = true
        
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        buttonView.layer.shadowRadius = 8
        buttonView.layer.shadowOpacity = 0.5
    }
    
    @objc private func searchButtonTapped() {
        print("searchButtonTapped")
    }
    @objc private func moreButtonTapped() {
        print("moreButtonTapped")
    }
    
    @objc private func floatingButtonTapped() {
        presentUsersListingVC()
    }
    
    private func listenToViewModel() {
        viewModal.friendsList.bind { (friendsList) in
            if !(friendsList?.isEmpty ?? false) {
                self.tableViewDataList = friendsList!
                self.tableView.reloadData()
            }
            self.activityIndicator?.stopAnimating()
        }
        
        viewModal.modifiedChats.bind { (chatThreads) in
            if !(chatThreads?.isEmpty ?? false) {
                var indexes: [Int] = []
                for chatThread in chatThreads! {
                    if let index = self.tableViewDataList.firstIndex(where: { $0.chatThreadId == chatThread }) {
                        indexes.append(index)
                    }
                }
                self.makeNewMessageIndication(indexes: indexes)
            }
        }
        
        viewModal.newFriendsList.bind { [weak self] (friends) in
            guard let friends = friends, friends.count > 0, let self = self else { return }
            let oldList = self.tableViewDataList
            self.tableViewDataList = friends
            self.tableViewDataList.append(contentsOf: oldList)
            let indexPaths = Array(0 ..< friends.count).map({ return IndexPath(item: $0, section: 0) })
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    private func makeNewMessageIndication(indexes: [Int]) {
        for index in indexes {
            newMessageUpdateIndexSet.insert(index)
        }
        tableView.reloadData()
    }
    
    private func presentLoginViewController() {
        let loginVC = LoginViewController()
        loginVC.delegate = self
        self.present(loginVC, animated: true, completion: nil)
        
    }
    
    private func presentUsersListingVC() {
        let addFriendListing = ListingViewController()
        self.navigationController?.pushViewController(addFriendListing, animated: true)
    }
    
    private func openChatViewController(friend: Friend) {
        let chatVC = ChatViewController()
        chatVC.chatThreadId = friend.chatThreadId
        chatVC.friendId = friend.userId
        chatVC.publicKey = friend.publicKey
        chatVC.name = friend.name
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
}

extension HomeViewController: LoginViewControllerDelegate {
    func LoginViewControllerUserLoginSuccess() {
        getFriendsList()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.cellIdentifier, for: indexPath) as? HomeTableViewCell else { return UITableViewCell()}
        cell.nameLabel.text = tableViewDataList[indexPath.item].name
        if let imageURL = tableViewDataList[indexPath.item].profileImage {
            cell.dpImageView.imageFrom(url: URL(string: imageURL)!)
        } else {
            cell.dpImageView.image = UIImage(named: "test")
        }
        cell.newMessageView.isHidden = !newMessageUpdateIndexSet.contains(indexPath.item)
        let bgColorView = UIView()
        bgColorView.backgroundColor = .clear
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item
        newMessageUpdateIndexSet.remove(indexPath.item)
        let friend = tableViewDataList[index]
        self.openChatViewController(friend: friend)
    }
}
