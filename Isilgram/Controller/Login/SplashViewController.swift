//
//  SplashViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/8/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SplashViewController: UIViewController {
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    
    var user: User!
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        user = Auth.auth().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.checkUserAuthentication()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: Created functions
    func checkUserAuthentication() {
        guard let user = user else {
            self.performSegue(withIdentifier: "NavSplashToLogin", sender: self)
            return
        }
        
        let uid = user.uid
        self.checkUserDatabase(uid: uid)
    }
    
    func checkUserDatabase(uid: String) {
        dbUsers.document(uid).getDocument { (document, err) in
            if err == nil {
                guard let document = document, document.exists else {
                    self.performSegue(withIdentifier: "NavSplashToSignIn", sender: self)
                    return
                }
                
                self.performSegue(withIdentifier: "NavSplashToMain", sender: nil)
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
}
