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
import FirebaseUI
import CodableFirebase

class PublishViewController: UIViewController {
    @IBOutlet weak var btnEnviarPost: UIButton!
    @IBAction func enviarPost(_ sender: Any) {
        btnEnviarPost.isEnabled = false
        uploadData()
    }
    @IBOutlet weak var tvMessage: UITextView!
    @IBOutlet weak var scrollImages: UIScrollView!
    var stgImages: StorageReference!

    
    @IBOutlet weak var tvHashtags: UITextView!
    var imagePickerController: UIImagePickerController?
    var defaultImageUrl: URL?
    var arrayImages: [UIImage]! = []
    var arrayImageNames: [String]! = []
    var arrayCategories: [String]! = []
    
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    
    var frame = CGRect(x: 0, y:0, width: 0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        tvMessage.isScrollEnabled = true
        tvMessage.sizeToFit()
        tvMessage.layoutIfNeeded()
        tvMessage.clipsToBounds = true
        tvHashtags.isScrollEnabled = true
        tvHashtags.sizeToFit()
        tvHashtags.layoutIfNeeded()
        tvHashtags.clipsToBounds = true
        
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
        let hashtags = tvHashtags.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let delimiter = " "
        var tags = hashtags.components(separatedBy: delimiter)
        
        ref = db.collection("posts").addDocument(data: [
            "author": user?.uid,
            "dateCreated": FieldValue.serverTimestamp(),
            "message": tvMessage.text ?? "",
            "categories": tags,
            "pictures": arrayImageNames,
            "likes" : [user?.uid]
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.uploadPictures(userId: self.user!.uid, postId: ref!.documentID, index: 0)

                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    func setImagesInSlider(){
        let imagesCount = arrayImages.count
         for index in 0..<imagesCount {
             frame.origin.x = 100 * CGFloat(index)
             frame.size = CGSize(width: 100, height: 100)
             let imageView = UIImageView(frame: frame)
             imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.image = arrayImages[index]
            
            
             let img = arrayImages[index]
            
             // margen cagando todo el contenido inset

             self.scrollImages.addSubview(imageView)
             }
         
         scrollImages.contentSize = CGSize(width: (100 * CGFloat(imagesCount)), height: scrollImages.frame.size.height)
         self.view.layoutIfNeeded()
         
    }
    
    func uploadPictures(userId: String, postId:String, index: Int) {
        stgImages = Storage.storage().reference().child(userId).child(postId)
        if index < arrayImages.count{
            let data = arrayImages[index].jpegData(compressionQuality: 0.3)
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let refUserPhoto = stgImages.child("\(index).jpg")
            print("Imagen: \(index)")
            SDWebImageManager.shared.imageCache.clear(with: .all, completion: nil)
            
            refUserPhoto.putData(data!, metadata: metaData) { (meta, err) in
                if err != nil {
                    print(err)
                }
                else {
                    self.uploadPictures(userId: userId, postId: postId, index: index+1)
                    print("Imagen: \(index + 1) subida")
                }
            }
        } else {
            //enviar a home view controllker
            let vc = storyboard?.instantiateViewController(withIdentifier: "PublishViewController") as? PublishViewController
            self.navigationController?.pushViewController(vc!, animated: false)
            Function.showAlert(context: self, title: "exito", message: "publicado", button: "Aceptar")
        }
    }
    

}

extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        
        self.arrayImages.append(image)
        self.arrayImageNames.append("\(arrayImages.count-1).jpg")

        print(arrayImages!)
        print(arrayImageNames!)
        setImagesInSlider()
        
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

 

extension PublishViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
          let fixedWidth = tvMessage.frame.size.width
          tvMessage.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
          let newSize = tvMessage.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
          var newFrame = tvMessage.frame
          newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
          tvMessage.frame = newFrame
    }

}
