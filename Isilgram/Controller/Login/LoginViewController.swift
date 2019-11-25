//
//  LoginViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/8/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FacebookLogin
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    @IBOutlet weak var txtEmail: CSMTextField!
    @IBOutlet weak var txtPassword: CSMTextField!    
    @IBOutlet weak var btnLogin: CSMButton!
    @IBOutlet weak var btnLoginFacebook: CSMButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        
        self.navigationItem.hidesBackButton = true
        self.hideKeyboardWhenTappedAround()
        Function.removeLastestViews(context: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    @IBAction func login(_ sender: Any) {
        if checkFields() {
            Function.enableDisableButton(button: btnLogin, value: false)
            Function.enableDisableButton(button: btnLoginFacebook, value: false)
            
            let email = txtEmail.text?.trim()
            let password = txtPassword.text
            checkUserAuthentication(email: email!, password: password!)
        }
    }
    
    @IBAction func loginFacebook(_ sender: Any) {
        Function.enableDisableButton(button: btnLoginFacebook, value: false)
        Function.enableDisableButton(button: btnLogin, value: false)
        
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
                case .success(granted: _, declined: _, token: _):
                    self.checkUserAuthenticationFacebook()
                case .failed(let err):
                    Function.showAlertError(context: self, err: err)
                Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
                case .cancelled:
                    Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
                    return
            }
        }
    }
    
    
    //MARK: Created Functions
    func checkFields() -> Bool {
        var result = true
        if Function.checkTextFieldEmail(textField: txtEmail) { result = false }
        if Function.checkTextFieldEmpty(textField: txtPassword) { result = false }
        
        return result
    }
    
    func checkUserAuthentication(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if err == nil {
                guard let user = result?.user else {
                    Function.showAlert(context: self, title: Constant.title_1, message: "No se obtuvo información de autenticación", button: Constant.button_accept)
                    Function.enableDisableButton(button: self.btnLogin, value: true)
                    Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
                    return
                }
                
                let uid = user.uid
                self.checkUserDatabase(uid: uid)
            }
            else {
                Function.showAlertError(context: self, err: err!)
                Function.enableDisableButton(button: self.btnLogin, value: true)
                Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
            }
        }
    }
    
    func checkUserAuthenticationFacebook() {
        let accessToken = AccessToken.current?.tokenString
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken!)
        Auth.auth().signIn(with: credentials) { (result, err) in
            if err == nil {
                guard let user = result?.user else {
                    Function.showAlert(context: self, title: Constant.title_1, message: "No se obtuvo información de autenticación", button: Constant.button_accept)
                    Function.enableDisableButton(button: self.btnLogin, value: true)
                    Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
                    return
                }
                
                let uid = user.uid
                self.checkUserDatabase(uid: uid)
            }
            else {
                Function.showAlertError(context: self, err: err!)
                Function.enableDisableButton(button: self.btnLogin, value: true)
                Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
            }
        }
    }
    
    func checkUserDatabase(uid: String) {
        dbUsers.document(uid).getDocument { (document, err) in
            if err == nil {
                guard let document = document, document.exists else {
                    self.performSegue(withIdentifier: "NavLoginToSignIn", sender: self)
                    return
                }
                
                self.performSegue(withIdentifier: "NavLoginToMain", sender: nil)
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
            
            Function.enableDisableButton(button: self.btnLogin, value: true)
            Function.enableDisableButton(button: self.btnLoginFacebook, value: true)
        }
    }
}
