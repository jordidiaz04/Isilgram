//
//  PostCollectionViewCell.swift
//  Isilgram
//
//  Created by Alumno on 11/27/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseUI

class PostCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ivPost: CSMImageView!
    
    
    //MARK: Variables and Components
    var objPost: PostBE! {
        didSet {
            self.loadImages()
        }
    }
    
    
    //MARK: Created Functions
    func loadImages() {
        let stgPost: StorageReference! = Storage.storage().reference().child(objPost.author!).child(objPost.id!)
        let refPhoto = stgPost.child(objPost.pictures?.first ?? "")
        ivPost.sd_setImage(with: refPhoto, placeholderImage: UIImage(named: "img_default"))
    }
}
