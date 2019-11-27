//
//  HomeViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        Function.removeLastestViews(context: self)
        let db = Firestore.firestore()
        db.collection("posts")
            .getDocuments { (snapshot, error) in
            if let error = error{
                print("error: \(error)")
            } else {
                for document in snapshot!.documents {
                    print(document)
                }
            }
            }
        
        print("entrasdxasxasxase!")
    }
}
