//
//  PostBE.swift
//  Isilgram
//
//  Created by Alumno on 11/27/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit

struct PostBE: Codable {
    var id: String? = ""
    var author: String? = ""
    var categories: [String]? = []
    var dateCreated: String? = ""
    var likes: [String]? = []
    var message: String? = ""
    var pictures: [String]? = []
}
