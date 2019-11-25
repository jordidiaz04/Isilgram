//
//  SignInViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/8/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SignInViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var txtFullName: CSMTextField!
    @IBOutlet weak var txtNickname: CSMTextField!
    @IBOutlet weak var txtBirthDate: CSMTextField!
    @IBOutlet weak var txtPhone: CSMTextField!
    @IBOutlet weak var txtEmail: CSMTextField!
    @IBOutlet weak var txtPassword: CSMTextField!
    @IBOutlet weak var txtConfirmPassword: CSMTextField!
    @IBOutlet weak var btnSignIn: CSMButton!
    
    //MARK: Variables and Components
    var objUserBE: UserBE!
    
    var dbUsers: CollectionReference!
    
    var user: User!
    
    var stgUser: StorageReference!
    
    var imagePickerController: UIImagePickerController?
    
    var defaultImageUrl: URL?
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(self.changeValueDatePicker(sender:)), for: UIControl.Event.valueChanged)
        
        return datePicker;
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        toolbar.barStyle = .blackTranslucent
        toolbar.tintColor = .white
        let btnToday = UIBarButtonItem(title: "Hoy", style: .plain, target: self, action: #selector(pressTodayButton(_:)))
        let btnDone = UIBarButtonItem(title: "Ok", style: .plain, target: self, action: #selector(pressDoneButton(_:)))
        let btnFlex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/3, height: 40))
        lblTitle.text = "Seleccione una fecha"
        lblTitle.textColor = .yellow
        lblTitle.textAlignment = .center
        lblTitle.font = .systemFont(ofSize: 17)
        let btnTitle = UIBarButtonItem(customView: lblTitle)
        toolbar.setItems([btnToday, btnFlex, btnTitle, btnFlex, btnDone], animated: true)
        
        return toolbar
    }()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        formatter.dateFormat = "dd/MM/yyyy"
        
        return formatter
    }()
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        user = Auth.auth().currentUser
        stgUser = Storage.storage().reference()
        
        ivPhoto.clipsToBounds = true
        txtBirthDate.inputView = datePicker
        txtBirthDate.inputAccessoryView = toolbar
        txtBirthDate.text = formatter.string(from: Date())
        
        self.hideKeyboardWhenTappedAround()
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
    
    @objc func changeValueDatePicker(sender: UIDatePicker) {
        txtBirthDate.text = formatter.string(from: sender.date)
    }
    
    @objc func pressTodayButton(_ sender: UIBarButtonItem) {
        txtBirthDate.text = formatter.string(from: Date())
        txtBirthDate.resignFirstResponder()
    }
    
    @objc func pressDoneButton(_ sender: UIBarButtonItem) {
        txtBirthDate.resignFirstResponder()
    }
    
    
    //MARK: IBAction Functions
    @IBAction func uploadPhoto(_ sender: Any) {
        if self.imagePickerController != nil {
            self.imagePickerController?.delegate = nil
            self.imagePickerController = nil
        }
        
        self.imagePickerController = UIImagePickerController.init()
        self.imagePickerController?.allowsEditing = true
        
        let alert = UIAlertController.init(title: "Seleccione una opción", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction.init(title: "Galeria", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .photoLibrary)
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func signIn(_ sender: Any) {
        if checkFields() {
            Function.enableDisableButton(button: btnSignIn, value: false)
            
            objUserBE = UserBE()
            objUserBE.fullName = (txtFullName.text?.trim())!
            objUserBE.nickName = (txtNickname.text?.trim())!
            objUserBE.birthDate = (txtBirthDate.text)!
            objUserBE.email = (txtEmail.text?.trim())!
            objUserBE.phone = (txtPhone.text)!
            objUserBE.password = (txtPassword.text)!
            objUserBE.namePhoto = "perfil"
            
            self.checkUserAuthentication()
        }
    }
    
    
    //MARK: Created Functions
    func presentImagePicker(controller: UIImagePickerController, source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        self.present(controller, animated: true)
    }
    
    func checkFields() -> Bool {
        var result = true
        if Function.checkTextFieldEmpty(textField: txtFullName) { result = false }
        if Function.checkTextFieldEmpty(textField: txtNickname) { result = false }
        if Function.checkAge(textField: txtBirthDate) { result = false }
        if Function.checkTextFieldEmpty(textField: txtPhone) { result = false }
        if Function.checkTextFieldEmail(textField: txtEmail) { result = false }
        if Function.checkTextFieldLength(textField: txtPassword, length: 6) { result = false }
        if Function.checkTextFieldCompare(textField1: txtConfirmPassword, textField2: txtPassword) { result = false }
        
        return result
    }
    
    func checkUserAuthentication() {
        if user == nil {
            self.signInAuthentication()
        }
        else {
            let uid = user.uid
            self.checkUserDatabase(uid: uid)
        }
    }
    
    func checkUserDatabase(uid: String) {
        dbUsers.document(uid).getDocument { (document, err) in
            if err == nil {
                if document!.exists {
                    Function.enableDisableButton(button: self.btnSignIn, value: true)
                    Function.showAlert(context: self, title: Constant.title_1, message: "Ya se encontraba registrado, si olvidó su contraseña regrese al inicio de sesión", button: Constant.button_accept)
                }
                else {
                    self.checkAuthenticationProvider()
                }
            }
            else {
                Function.enableDisableButton(button: self.btnSignIn, value: true)
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    
    func checkAuthenticationProvider() {
        if let providerData = user?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    let uid = user.uid
                    self.signInDatabase(uid: uid)
                    break
                default:
                    self.signInAuthentication()
                }
            }
        }
    }
    
    func signInAuthentication() {
        Auth.auth().createUser(withEmail: objUserBE.email, password: objUserBE.password) { (result, err) in
            if err == nil {
                guard let user = result?.user else {
                    Function.enableDisableButton(button: self.btnSignIn, value: true)
                    Function.showAlert(context: self, title: Constant.title_1, message: "No se pudo completar el registro de autenticación", button: Constant.button_accept)
                    return
                }
                
                self.user = user
                let uid = user.uid
                self.uploadPhotoToStorage()
                self.signInDatabase(uid: uid)
            }
            else {
                Function.enableDisableButton(button: self.btnSignIn, value: true)
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    
    func signInDatabase(uid: String) {
        let data = try! FirestoreEncoder().encode(objUserBE)
        dbUsers.document(uid).setData(data) { err in
            if err == nil {
                let acAccept = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                    self.performSegue(withIdentifier: "NavSignInToMain", sender: nil)
                }
                Function.showAlert(context: self, title: Constant.title_1, message: "Registro exitoso", action: acAccept)
            }
            else {
                Function.enableDisableButton(button: self.btnSignIn, value: true)
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    
    func uploadPhotoToStorage() {
        let data = ivPhoto.image?.jpegData(compressionQuality: 1.0)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let refUserPhoto = stgUser.child(user.uid).child(objUserBE.namePhoto)
        
        refUserPhoto.putData(data!, metadata: metaData) { (meta, err) in
            if err != nil {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
}

extension SignInViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        
        self.ivPhoto.image = image
        picker.dismiss(animated: true) {
            picker.delegate = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.delegate = nil
        }
    }
}
