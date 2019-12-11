//
//  PostBE.swift
//  Isilgram
//
//  Created by Alumno on 11/27/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import CodableFirebase
import FirebaseFirestore

struct PostBE: Codable {
    var id: String? = ""
    var author: String? = ""
    var authorDisplayName: String? = ""
    var authorDetails: UserBE? = UserBE()
    var categories: [String]? = []
    var dateCreated: Timestamp?
    var likes: [String]? = []
    var message: String? = ""
    var pictures: [String]? = []
}

