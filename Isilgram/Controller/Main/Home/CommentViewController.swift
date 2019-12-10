//
//  CommentViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 12/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    var idPost: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Comments: " + idPost)
    }
}
