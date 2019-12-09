//
//  EditAccountViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/12/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseUI
import CodableFirebase
import CodableFirebase

class EditAccountViewController: UIViewController {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var txtFullName: CSMTextField!
    @IBOutlet weak var txtNickName: CSMTextField!
    @IBOutlet weak var txtBirthDate: CSMTextField!
    @IBOutlet weak var txtPhone: CSMTextField!
    @IBOutlet weak var txtEmail: CSMTextField!
    @IBOutlet weak var btnSave: CSMButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    //MARK: Variables and Components
    var isChangeImage: Bool!
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
        
        self.hideKeyboardWhenTappedAround()
        getUserInformation()
        loadUserPhoto()
        
        ivPhoto.clipsToBounds = true
        txtBirthDate.inputView = datePicker
        txtBirthDate.inputAccessoryView = toolbar
        txtBirthDate.text = formatter.string(from: Date())
    }
    override func viewWillAppear(_ animated: Bool) {
        isChangeImage = false
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
    @IBAction func save(_ sender: Any) {
        if checkFields() {
            Function.enableDisableButton(button: btnSave, value: false)
            
            objUserBE.fullName = (txtFullName.text?.trim())!
            objUserBE.nickName = (txtNickName.text?.trim())!
            objUserBE.birthDate = txtBirthDate.text!
            objUserBE.phone = txtPhone.text!
            objUserBE.email = (txtEmail.text?.trim())!
            objUserBE.namePhoto = "perfil"
            
            checkUserAuthentication()
            if isChangeImage {
                uploadPhotoToStorage()
                SDWebImageManager.shared.imageCache.clear(with: .all, completion: nil)
            }
        }
    }
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
    func presentImagePicker(controller: UIImagePickerController, source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        self.present(controller, animated: true)
    }
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
                
                self.objUserBE = try! FirestoreDecoder().decode(UserBE.self, from: data)
                self.loadUserInformation()
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    func loadUserInformation() {
        txtNickName.text = objUserBE.nickName
        txtFullName.text = objUserBE.fullName
        txtBirthDate.text = objUserBE.birthDate
        txtPhone.text = objUserBE.phone
        txtEmail.text = objUserBE.email
    }
    func loadUserPhoto() {
        let refStorage = stgUser.child(user.uid).child("perfil")
        self.ivPhoto.sd_setImage(with: refStorage)
    }
    func checkFields() -> Bool {
        var result = true
        if Function.checkTextFieldEmpty(textField: txtFullName) { result = false }
        if Function.checkTextFieldEmpty(textField: txtNickName) { result = false }
        if Function.checkAge(textField: txtBirthDate) { result = false }
        if Function.checkTextFieldEmpty(textField: txtPhone) { result = false }
        if Function.checkTextFieldEmail(textField: txtEmail) { result = false }
        
        return result
    }
    func checkUserAuthentication() {
        if user == nil {
            Function.enableDisableButton(button: btnSave, value: true)
            Function.showAlert(context: self, title: Constant.title_1, message: "No se pudo obtener la información del usuario", button: Constant.button_accept)
        }
        else {
            if user.email == objUserBE.email {
                updateUserInformation(uid: user.uid)
            }
            else {
                checkAuthenticationProvider()
            }
        }
    }
    func checkAuthenticationProvider() {
        if let providerData = user?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    self.updateUserInformation(uid: user.uid)
                    break
                default:
                    self.updateAuthenticationInformation(email: objUserBE.email)
                }
            }
        }
    }
    func updateAuthenticationInformation(email: String) {
        user.updateEmail(to: email) { (err) in
            if err == nil {
                self.updateUserInformation(uid: self.user.uid)
            }
            else {
                Function.showAlertError(context: self, err: err!)
            }
        }
    }
    func updateUserInformation(uid: String) {
        let data = try! FirestoreEncoder().encode(objUserBE)
        dbUsers.document(uid).setData(data) { (err) in
            if let err = err {
                Function.showAlertError(context: self, err: err)
            }
            else {
                let acAccept = UIAlertAction(title: "Aceptar", style: .default) { (action) in
                    self.navigationController?.popViewController(animated: true)
                }
                Function.showAlert(context: self, title: Constant.title_1, message: "Actualización de información exitosa", action: acAccept)
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

extension EditAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
        
        self.ivPhoto.image = image
        self.isChangeImage = true
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
