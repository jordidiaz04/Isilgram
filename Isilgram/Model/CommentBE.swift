//
//  CommentBE.swift
//  Isilgram
//
//  Created by Autopsia on 12/9/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import CodableFirebase
import FirebaseFirestore

struct CommentBE: Codable {
    var id: String? = ""
    var author: String? = ""
    var dateCreated: Timestamp?
    var message: String? = ""

}
