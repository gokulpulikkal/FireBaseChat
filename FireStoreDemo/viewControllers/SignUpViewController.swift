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
import PhotosUI

protocol SignUpViewControllerDelegate: NSObjectProtocol {
    func signUpViewController(userCreated withId: String?, userName: String?)
}

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var imagePickerView: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var mailIdTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    weak var delegate: SignUpViewControllerDelegate?
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SignUp Page"
        initializeHideKeyboard()
        adjustUIViews()
        
        let imagePickerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImagePickerView))
        imagePickerView.addGestureRecognizer(imagePickerTapRecognizer)
    }
    
    func adjustUIViews() {
        view.backgroundColor = UIColor.getColor(R: 38, G: 36, B: 49)
        
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.cornerRadius = 40
        profilePhoto.clipsToBounds = true
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
    
    @objc func didTapImagePickerView() {
        showImagePickerOptions()
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
                    self.delegate?.signUpViewController(userCreated: userResult?.user.uid, userName: self.userNameTextField.text)
                }
            }
        }
    }
    
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider{
          
            if itemProvider.canLoadObject(ofClass: UIImage.self){
                itemProvider.loadObject(ofClass: UIImage.self) { image , error  in
                    if let error{
                        print(error)
                    }
                    if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async {
                            self.profilePhoto.image = selectedImage
                        }
                    }
                }
            }
            
        }
    }
}

extension SignUpViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.profilePhoto.image = image
        self.dismiss(animated: true)
    }
}
