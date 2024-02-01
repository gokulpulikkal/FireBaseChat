//
//  BaseViewController.swift
//  FireStoreDemo
//
//  Created by Gokul P on 19/01/24.
//  Copyright © 2024 Gokul. All rights reserved.
//

import UIKit
import PhotosUI

class BaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    

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

}
