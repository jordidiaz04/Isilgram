//
//  Constant.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/9/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit

struct Constant {
    //MARK: Constantes con referencia a la base de datos
    static let dbRefUser = "users"
    static let dbRefFollowers = "followers"
    static let dbRefPost = "posts"
    
    //MARK: Contantes para validar campos
    static let borderColorTextField = UIColor(red: (0 / 255), green: (144 / 255), blue: (198 / 255), alpha: 1).cgColor
    static let borderErrorColorTextField = UIColor(red: (255 / 255), green: (38 / 255), blue: (0 / 255), alpha: 1).cgColor
    
    //MARK: Mensajes
    static let title_1 = "Mensaje al usuario"
    static let title_error = "Mensaje de error"
    static let button_accept = "Aceptar"
    static let button_cancel = "Cancelar"
}
