//
//  RecoverViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/8/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import Firebase

class RecoverViewController: UIViewController {
    @IBOutlet weak var txtEmail: CSMTextField!
    @IBOutlet weak var btnSend: CSMButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    //MARK: Funciones selector
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
    @IBAction func sendEmail(_ sender: Any) {
        if checkFields() {
            Function.enableDisableButton(button: btnSend, value: false)
            
            let email = txtEmail.text?.trim()
            sendRecoverEmail(email: email!)
        }
    }
    
    
    //MARK: Created Functions
    func checkFields() -> Bool {
        var result = true
        if Function.checkTextFieldEmail(textField: txtEmail) { result = false }
        
        return result
    }
    
    func sendRecoverEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if err == nil {
                let acAccept = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                Function.showAlert(context: self, title: Constant.title_1, message: "Se le envío un correo, donde podrá realizar el cambio de su contraseña.", action: acAccept)
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
}
