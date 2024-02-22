//
//  LoginViewController.swift
//  FireStoreDemo
//
//  Created by Gokul on 11/07/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import Firebase

protocol LoginViewControllerDelegate: NSObjectProtocol {
    func LoginViewControllerUserLoginSuccess()
}

class LoginViewController: BaseViewController {

    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    weak var delegate: LoginViewControllerDelegate?

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        navigationItem.title = "Login"
        // Do any additional setup after loading the view.
        reference = db.collection("users")
        openHomeViewController()
        createViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        databaseListener = reference?.addSnapshotListener({ (querySnapShot, error) in
//            if let querySnapShots = querySnapShot {
//                for document in querySnapShots.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        })
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    private func createViews() {
        let screenSize = UIScreen.main.bounds
        let userNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width * 0.6, height: 50))
        let passWordLabel = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width * 0.6, height: 50))
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, passWordLabel])
        stackView.axis = .vertical
        self.view.addSubview(stackView)
        stackView.centerInSuperview()
    }

    private func openHomeViewController() {
        let homeVC = HomeViewController()
        homeVC.view.backgroundColor = .red
        self.navigationController?.pushViewController(homeVC, animated: true)
    }
    
    deinit {
        print("deinited Login controller")
    }
    
    @IBAction func didPressLogIn(_ sender: Any) {
        guard let mail = userNameField.text, let password = passwordField.text else { return }
        Auth.auth().signIn(withEmail: mail, password: password) { [weak self] (response, error) in
            if error == nil {
                print("Signing in success")
                UserData.shared.userName = response?.user.displayName
                self?.saveUserAndDismissViewController(userId: response?.user.uid, userName: response?.user.displayName)
                
                
//                self?.reference?.addDocument(data: ["first": "gokul",
//                "last": "p",
//                "born": 1996], completion: { (error) in
//                    if error != nil {
//                        print("saving document error")
//                    }
//                })
            }
            
        }
    }

    @IBAction func pressedSignUp(_ sender: Any) {
        let signupVC = SignUpViewController()
        signupVC.delegate = self
        self.present(signupVC, animated: true, completion: nil)
    }
    
    private func saveUserAndDismissViewController(userId: String?, userName: String?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userId, forKey: BaseViewController.userIdKey)
        userDefaults.set(userName, forKey: BaseViewController.userName)
        delegate?.LoginViewControllerUserLoginSuccess()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension LoginViewController: SignUpViewControllerDelegate {
    func signUpViewController(userCreated withId: String?, userName: String?) {
        print("SignUp success")
        self.saveUserAndDismissViewController(userId: withId, userName: userName)
    }
}
