//
//  PublishViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/16/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CodableFirebase

class PublishViewController: UIViewController {
    @IBOutlet weak var ivPhoto: CSMImageView!
    
    var imagePickerController: UIImagePickerController?
    var defaultImageUrl: URL?
    var arrayImages: [UIImage]!
    var arrayImageNames: [String]!
    var arrayCategories: [String]!
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayImages = []
        arrayImageNames = []
        arrayCategories = []
        uploadData()
    }
    
    
    @IBAction func pickOrTakePicture(_ sender: Any) {
        if self.imagePickerController != nil {
            self.imagePickerController?.delegate = nil
            self.imagePickerController = nil
        }
        
        self.imagePickerController = UIImagePickerController.init()
        self.imagePickerController?.allowsEditing = true
        
        let alert = UIAlertController.init(title: "Seleccione una opción", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction.init(title: "Camera", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction.init(title: "Galeria", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .photoLibrary)
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    func presentImagePicker(controller: UIImagePickerController, source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        self.present(controller, animated: true)
    }
    func uploadData() {
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data: [
            "author": user?.uid,
            "dateCreated": FieldValue.serverTimestamp(),
            "message": "Esto es una prueba",
            "pictures": ["perfil"]
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}

extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        
        self.ivPhoto.image = image
        
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
        }
    }
}
