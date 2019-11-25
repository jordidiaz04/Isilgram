//
//  AccountViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseUI

class AccountViewController: UIViewController {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var lblNickname: CSMLabel!
    @IBOutlet weak var lblFullName: CSMLabel!
    @IBOutlet weak var lblBirthDate: CSMLabel!
    @IBOutlet weak var lblPhone: CSMLabel!
    @IBOutlet weak var lblEmail: CSMLabel!
    @IBOutlet weak var btnEdit: CSMButton!
    @IBOutlet weak var btnLogout: CSMButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    
    var user: User!
    
    var stgUser: StorageReference!
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        user = Auth.auth().currentUser
        stgUser = Storage.storage().reference()
        
        getUserInformation()
        
        ivPhoto.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        loadUserPhoto()
    }
    
    
    //MARK: Selector Functions
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    
    //MARK: IBAction Functions    
    @IBAction func logOut(_ sender: Any) {
        let acYes = UIAlertAction(title: "Si", style: .default) { (action) in
            do {
                try! Auth.auth().signOut()
                self.parent?.parent?.performSegue(withIdentifier: "NavMainToLogin", sender: nil)
            }
        }
        let acNo = UIAlertAction(title: "No", style: .default) { (action) in
            return
        }
        
        Function.showAlert(context: self, title: Constant.title_1, message: "¿Desea cerrar su sesión?", action1: acYes, action2: acNo)
    }
    
    
    //MARK: Created Functions
    func getUserInformation() {
        let menssageNoInformation = "No se pudo obtener información del usuario"
        guard let user = user else {
            Function.showAlert(context: self, title: Constant.title_1, message: menssageNoInformation, button: Constant.button_accept)
            return
        }
        
        dbUsers.document(user.uid).addSnapshotListener { (documentSnapshot, err) in
            if err == nil {
                guard let document = documentSnapshot else {
                    Function.showAlert(context: self, title: Constant.title_1, message: menssageNoInformation, button: Constant.button_accept)
                    return
                }
                guard let data = document.data() else {
                    Function.showAlert(context: self, title: Constant.title_1, message: menssageNoInformation, button: Constant.button_accept)
                    return
                }
                
                let objUserBE = try! FirestoreDecoder().decode(UserBE.self, from: data)
                self.loadUserInformation(obj: objUserBE)
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    
    func loadUserInformation(obj: UserBE) {
        lblNickname.text = obj.nickName
        lblFullName.text = obj.fullName
        lblBirthDate.text = obj.birthDate
        lblPhone.text = obj.phone
        lblEmail.text = obj.email
    }
    
    func loadUserPhoto() {
        let refStorage = stgUser.child(user.uid).child("perfil")
        self.ivPhoto.sd_setImage(with: refStorage)
    }
}
