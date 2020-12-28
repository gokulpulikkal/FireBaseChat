//
//  ChatViewController.swift
//  FireStoreDemo
//
//  Created by Gokul on 08/08/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    private let db = Firestore.firestore()
    let userId = UserDefaults.standard.value(forKey: LoginViewController.userIdKey) as? String
    var friendId: String?
    var name: String?
    var chatThreadId: String? {
        didSet {
            getChatMessages()
        }
    }
    private let primaryBackgroundColour = UIColor.getColor(R: 38, G: 36, B: 49)
    private let normalBottomAnchorConstant: CGFloat = 0
    private var bottomConstraint: NSLayoutConstraint?
    private var dataList: [BaseChatModel] = []
    
    lazy var chatCollectionView: UICollectionView = {
        
        let coll = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        coll.translatesAutoresizingMaskIntoConstraints = false
        coll.delegate = self
        coll.dataSource = self
        coll.backgroundColor = primaryBackgroundColour
        coll.keyboardDismissMode = .interactive
        return coll
    }()
    
    var inputTextView: UITextField = {
        let textView = UITextField(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    var sendButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "sendIcon"), for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        view.addTarget(self, action: #selector(didTappedSendButton), for: .touchUpInside)
        return view
    }()
    
    var attachButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "clip"), for: .normal)
//        view.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    var smileyButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "smileyFace"), for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    var inputContainerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    var containerView: UIView = {
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
        setUpCollectionView()
        setUpInputView()
        constrainViews()
        addTapGesture()
        observeNotifications()
        if let userName = UserDefaults.standard.value(forKey: LoginViewController.userName) as? String {
            print("userName is \(userName)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.getColor(R: 38, G: 36, B: 49)
        navigationItem.title = name
        
        let customButton = UIButton(frame: .zero)
        customButton.contentMode = .scaleAspectFit
        customButton.setImage(UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        customButton.width(35)
        customButton.height(35)
        customButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let customButton2 = UIButton(frame: .zero)
        customButton2.contentMode = .scaleAspectFit
        customButton2.setImage(UIImage(named: "vertical_menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        customButton2.contentMode = .scaleAspectFit
        customButton2.tintColor = UIColor.getColor(R: 46, G: 116, B: 254)
        customButton2.width(28)
        customButton2.height(28)
//        customButton2.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)

        let moreIcon = UIBarButtonItem(customView: customButton2)
        let backIcon = UIBarButtonItem(customView: customButton)
        navigationItem.leftBarButtonItems = [backIcon]
        navigationItem.rightBarButtonItems = [moreIcon]
    }
    
    deinit {
        print("deinited ChatVC")
    }
    
    private func getChatMessages() {
        db.collection("Chats").document(chatThreadId!).collection("messages").addSnapshotListener { documentSnapshots, error in
            
            guard let documentSnapshots = documentSnapshots else {
                print("Error fetching document: \(error!)")
                return
            }
            guard documentSnapshots.documents.count > 0 else {
                print("Document data was empty.")
                return
            }
            var messageList: [BaseChatModel] = []
            for document in documentSnapshots.documents {
                let dictionary = document.data()
                messageList.append(BaseChatModel(date: dictionary["date"] as? Timestamp ?? Timestamp(date: Date()), id: dictionary["id"] as? String ?? "", message: dictionary["message"] as? String ?? ""))
            }
            guard messageList.count > 0 else { return }
            self.dataList = messageList.sorted(by: { $0.date.dateValue() < $1.date.dateValue() })
            self.chatCollectionView.reloadData()
            self.chatCollectionView.scrollToItem(at: IndexPath(item: self.dataList.count - 1, section: 0) , at: .bottom, animated: false)
        }
        
    }
    
    private func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setUpCollectionView() {
        self.containerView.addSubview(chatCollectionView)
        chatCollectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.cellIdentifier)
    }
    
    private func setUpInputView() {
        self.containerView.addSubview(inputContainerView)
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(attachButton)
        inputContainerView.addSubview(smileyButton)
        containerView.addSubview(sendButton)
        inputTextView.delegate = self
        inputTextView.textColor = .white
        inputTextView.attributedPlaceholder = NSAttributedString(string: "Type something...", attributes:  [NSAttributedString.Key.foregroundColor: UIColor.getColor(R: 109, G: 110, B: 128).withAlphaComponent(0.7)])
        inputContainerView.backgroundColor = UIColor.getColor(R: 30, G: 28, B: 40)
        inputContainerView.layer.cornerRadius = 5
    }
    
    private func constrainViews() {
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
        
        chatCollectionView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0).isActive = true
        chatCollectionView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0).isActive = true
        chatCollectionView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0).isActive = true
        inputContainerView.topAnchor.constraint(equalTo: chatCollectionView.bottomAnchor, constant: 20).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 55).isActive = true
        inputContainerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10).isActive = true
        inputContainerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.75).isActive = true
//        inputContainerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10).isActive = true
        inputContainerView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20).isActive = true
        
        inputTextView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 10).isActive = true
        //inputTextView.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 5).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: -10).isActive = true
        inputTextView.centerYToSuperview()
//        inputTextView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7).isActive = true
        inputTextView.trailingAnchor.constraint(equalTo: attachButton.leadingAnchor, constant: -8).isActive = true
        
        smileyButton.centerYToSuperview()
        smileyButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -15).isActive = true
        smileyButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        smileyButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        attachButton.centerYToSuperview()
        attachButton.trailingAnchor.constraint(equalTo: smileyButton.leadingAnchor, constant: -10).isActive = true
        attachButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        attachButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        
//        sendButton.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 5).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
//        sendButton.centerYToSuperview()
        sendButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.23).isActive = true
        
    }
    
    @objc private func backButtonTapped() {
        print("back button pressed")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapped() {
        view.endEditing(true)
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print(keyboardSize)
            bottomConstraint?.constant = -keyboardSize.height
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc private func keyboardHide(notification: NSNotification) {
        bottomConstraint?.constant = normalBottomAnchorConstant
    }
    
    @objc private func didTappedSendButton() {
        let text = inputTextView.text
        guard text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return }
        let reference = db.collection("Chats").document(chatThreadId!).collection("messages")
        let friendDocument = db.collection("users").document(friendId!).collection("friends").document(userId!)
        
        friendDocument.setData([ "latestTime": Timestamp(date: Date()) ], merge: true)
        
        let chat = BaseChatModel(date: Timestamp(date: Date()), id: userId!, message: text)
        inputTextView.text = ""
        let docData: [String: Any] = [
            "id": chat.senderId as Any,
            "message": chat.message,
            "date": Timestamp(date: Date())
        ]
        reference.addDocument(data: docData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added ")
            }
        }
    }
    //MARK:- Cell Height Calculations
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: chatCollectionView.frame.width, height: 0)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
        return estimatedFrame
    }
    
    private func setUpChatCell(chatModel: BaseChatModel, cell: ChatCell) {
        if chatModel.senderId == UserDefaults.standard.value(forKey: LoginViewController.userIdKey) as? String {
            cell.bubbleBackgroundView.backgroundColor = UIColor.getColor(R: 40, G: 89, B: 251)
            cell.textLabel.textColor = .white
            cell.textViewLeadingAnchor?.isActive = true
            cell.textViewTrailingAnchor?.isActive = false
        } else {
            cell.bubbleBackgroundView.backgroundColor = UIColor.getColor(R: 52, G: 49, B: 69)
            cell.textLabel.textColor = .white
            cell.textViewLeadingAnchor?.isActive = false
            cell.textViewTrailingAnchor?.isActive = true
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension ChatViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.cellIdentifier, for: indexPath) as? ChatCell else { return UICollectionViewCell() }
        cell.setDataToViews(chatData: dataList[indexPath.item])
        setUpChatCell(chatModel: dataList[indexPath.item], cell: cell)
        return cell
    }
    
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width
        let text = dataList[indexPath.item].message
        let estimatedFrame = estimateFrameForText(text: text)
        return CGSize(width: width, height: estimatedFrame.height + 40)

    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
}
