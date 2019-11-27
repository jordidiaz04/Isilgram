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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var clvPosts: UICollectionView!
    
    
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
        
        ivPhoto.clipsToBounds = true
        
        getUserInformation()
        loadUserPhoto()
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
    }
    func loadUserPhoto() {
        let refStorage = stgUser.child(user.uid).child("perfil")
        self.ivPhoto.sd_setImage(with: refStorage)
    }
}