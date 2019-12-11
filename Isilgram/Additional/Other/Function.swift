//
//  Function.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/9/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import Firebase

class Function {
    //MARK: Valida los campos
    static func checkTextFieldEmpty(textField: CSMTextField) -> Bool {
        let texto = textField.text?.trim()
        
        if texto!.isEmpty {
            textField.layer.borderColor = Constant.borderErrorColorTextField
            return true
        }
        else {
            textField.layer.borderColor = Constant.borderColorTextField
            return false
        }
    }
    
    static func checkTextFieldLength(textField: CSMTextField, length: Int) -> Bool {
        let texto = textField.text?.trim()
        let value = textField.text?.trim().count
        
        if value! < length || texto!.isEmpty {
            textField.layer.borderColor = Constant.borderErrorColorTextField
            return true
        }
        else {
            textField.layer.borderColor = Constant.borderColorTextField
            return false
        }
    }
    
    static func checkTextFieldCompare(textField1: CSMTextField, textField2: CSMTextField) -> Bool {
        let texto1 = textField1.text
        let texto2 = textField2.text
        
        if texto1! != texto2 || texto1!.trim().isEmpty {
            textField1.layer.borderColor = Constant.borderErrorColorTextField
            return true
        }
        else {
            textField1.layer.borderColor = Constant.borderColorTextField
            return false
        }
    }
    
    static func checkTextFieldEmail(textField: CSMTextField) -> Bool {
        let text = textField.text?.trim()
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if emailPred.evaluate(with: text) && !text!.contains("yopmail") {
            textField.layer.borderColor = Constant.borderColorTextField
            return false
        }
        else {
            textField.layer.borderColor = Constant.borderErrorColorTextField
            return true
        }
    }
    
    
    //MARK: Muestra mensajes de alerta al realizar alguna acción
    static func showAlert(context: UIViewController, title: String, message: String, button: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: button, style: .default, handler: nil))
        context.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(context: UIViewController, title: String, message: String, action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        context.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(context: UIViewController, title: String, message: String, action1: UIAlertAction, action2: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action1)
        alert.addAction(action2)
        context.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertError(context: UIViewController, err: Error) {
        let error = err as NSError
        let title = Constant.title_error
        let button = Constant.button_accept
        
        print(error)
        
        switch error.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            showAlert(context: context, title: title, message: "El correo ya está siendo usado", button: button)
        case AuthErrorCode.weakPassword.rawValue:
            showAlert(context: context, title: title, message: "La contraseña ingresada es vulnerable", button: button)
        case AuthErrorCode.userNotFound.rawValue:
            showAlert(context: context, title: title, message: "El correo no se encuentra registrado", button: button)
        case AuthErrorCode.wrongPassword.rawValue:
            showAlert(context: context, title: title, message: "Email y/o contraseña incorrecta", button: button)
        default:
            showAlert(context: context, title: title, message: error.localizedDescription, button: button)
        }
    }
    
    
    //MARK:Funciones adicionales con componentes
    static func enableDisableButton(button: CSMButton, value: Bool) {
        button.isEnabled = value
        if value { button.alpha = 1 } else { button.alpha = 0.5 }
    }
    
    static func convertStringToDate(strDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        guard let date = formatter.date(from: strDate) else {
            return Date()
        }
        
        return date
    }
    
    static func checkAge(textField: CSMTextField) -> Bool {
        let strDate = textField.text
        let calendar = Calendar.current
        let birthDate = convertStringToDate(strDate: strDate!)
        let today = Date()
        let components = calendar.dateComponents([.year], from: birthDate, to: today)
        let age = components.year
        
        if age! >= 18 {
            textField.layer.borderColor = Constant.borderColorTextField
            return false
        }
        else {
            textField.layer.borderColor = Constant.borderErrorColorTextField
            return true
        }
    }
    
    static func removeLastestViews(context: UIViewController){
        //context.navigationController?.viewControllers.removeFirst()
        print("Aca estan los stacks")
        print(context.navigationController?.viewControllers)
    }
}
