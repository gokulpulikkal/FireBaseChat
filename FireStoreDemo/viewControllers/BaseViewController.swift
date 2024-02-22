//
//  BaseViewController.swift
//  FireStoreDemo
//
//  Created by Gokul P on 19/01/24.
//  Copyright © 2024 Gokul. All rights reserved.
//

import UIKit
import PhotosUI
import CryptoKit

class BaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {

    static let userIdKey = "userId"
    static let userName = "userName"
    static let privateKey = "privateKey"
    static let publicKey = "publicKey"
    static let profileImageURL = "profileImageURL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showImagePickerOptions() {
        let alertVC = UIAlertController(title: "Select your profile photo", message: "choose the source from which you wanna load you amazing photo", preferredStyle: .actionSheet)
        // option for camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            let cameraImagePicker = imagePicker(sourceType: .camera)
            self.present(cameraImagePicker, animated: true) {
                
            }
        }
        // Chose from gallery
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] (action) in
            guard let self = self else { return }
            
            var configuration = PHPickerConfiguration()
            //0 - unlimited 1 - default
            configuration.selectionLimit = 1
            configuration.filter = .images
            let pickerViewController = PHPickerViewController(configuration: configuration)
            pickerViewController.delegate = self
            present(pickerViewController, animated: true)
        }
        //Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = sourceType
        imagePickerVC.delegate = self
        return imagePickerVC
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
    }
    
    // Encryption
    func getEncryptionKeys() -> (publicKey: P384.KeyAgreement.PublicKey, privateKey: P384.KeyAgreement.PrivateKey ) {
        // The private and public encryption key of the receiver
        let recipientPrivateKey = P384.KeyAgreement.PrivateKey()
        let recipientPublicKey = recipientPrivateKey.publicKey
        return (recipientPublicKey, recipientPrivateKey)
    }

}
