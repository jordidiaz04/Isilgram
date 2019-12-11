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
import CodableFirebase

class AccountViewController: UIViewController {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var lblNickname: CSMLabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var clvPosts: UICollectionView!
    
    
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    var dbPosts: CollectionReference!
    var user: User!
    var stgUser: StorageReference!
    var arrayPosts: [PostBE]!
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        dbPosts = Firestore.firestore().collection(Constant.dbRefPost)
        user = Auth.auth().currentUser
        stgUser = Storage.storage().reference()
        arrayPosts = []
        
        ivPhoto.clipsToBounds = true
        
        getUserInformation()
        loadMyPosts()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserPhoto()
    }
    
    
    //MARK: Created Functions
    func getUserInformation() {
        let menssageNoInformation = "No se pudo obtener información del usuario"
        guard let user = user else {
            Function.showAlert(context: self, title: Constant.title_1, message: menssageNoInformation, button: Constant.button_accept)
            return
        }
        
        dbUsers.document(user.uid).addSnapshotListener { (documentSnapshot, err) in
            self.arrayPosts.removeAll()
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
        let refPhoto = stgUser.child(user.uid).child("perfil")
        ivPhoto.sd_setImage(with: refPhoto, placeholderImage: UIImage(named: "img_default"))
    }
    func loadMyPosts() {
        dbPosts.whereField("author", isEqualTo: user.uid).addSnapshotListener { (snapshot, err) in
            if let err = err {
                Function.showAlertError(context: self, err: err)
            }
            else {
                for document in snapshot!.documents {
                    var objPostBE = try! FirestoreDecoder().decode(PostBE.self, from: document.data())
                    objPostBE.id = document.documentID
                    self.arrayPosts.append(objPostBE)
                }
                
                self.clvPosts.reloadData()
            }
        }
    }
}

extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayPosts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "PostCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PostCollectionViewCell
        cell.objPost = self.arrayPosts[indexPath.row]
        
        return cell
    }
    
    
    //MARK: Funciones para dar tamaño a la celda
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.size.width/3, height: view.bounds.size.width/3)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
