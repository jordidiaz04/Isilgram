//
//  HomePostImageCollectionViewCell.swift
//  Isilgram
//
//  Created by Autopsia on 12/8/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class HomePostImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var height4Images: NSLayoutConstraint!
    let storage = Storage.storage()

    var userId: String!
    
    var imgUrl: String! {
        didSet{
            self.loadImages()
        }
    }
    
    func loadImages() {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(userId ?? "")
        let img = imgUrl ?? ""
        print(img)
        let spaceRef = imagesRef.child("perfil")
        
        self.imgPost.sd_setImage(with: spaceRef, placeholderImage: UIImage(named: "logo")) { (image, error, typeCache, storageReference) in
            let imageSize = image?.size ?? .zero
            let newHeight = UIScreen.main.bounds.width * imageSize.height / UIScreen.main.bounds.width
            self.imgPost.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: newHeight)
            self.height4Images.constant = newHeight
            print(img)
        }
        
    }
}