//
//  SignUpViewController.swift
//  FireStoreDemo
//
//  Created by Gokul on 17/05/20.
//  Copyright © 2020 Gokul. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol SignUpViewControllerDelegate: NSObjectProtocol {
    func signUpViewController(userCreated withId: String?)
}

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var mailIdTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    weak var delegate: SignUpViewControllerDelegate?
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SignUp Page"
        initializeHideKeyboard()
        
    }
    
    private func addUserToFireStoreDatabase(userId: String?, userName: String?) {
        guard let userId = userId else { return }
        db.collection("users").document(userId).setData([
            "name": userName as Any,
            "userId": userId
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                let userDefaults = UserDefaults.standard
                userDefaults.set(userId, forKey: LoginViewController.userIdKey)
                userDefaults.set(userName, forKey: LoginViewController.userName)
            }
        }
    }
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboard))
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
    deinit {
        print("deinited signup controller")
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        guard let email = mailIdTextView.text, let password = passwordTextView.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (userResult, error) in
            if error == nil {
                self.addUserToFireStoreDatabase(userId: userResult?.user.uid, userName: self.userNameTextField.text)
                self.dismiss(animated: true) {
                    self.delegate?.signUpViewController(userCreated: userResult?.user.uid)
                }
            }
        }
    }
}
