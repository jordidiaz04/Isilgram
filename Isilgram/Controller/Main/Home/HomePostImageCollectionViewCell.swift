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
    
    var imageBE: ImageBE! {
        didSet{
            self.loadImages()
        }
    }
    
    func loadImages() {
        let storageRef = storage.reference()
        let userid = imageBE.userId
        let img = imageBE.imageUrl
        let postid = imageBE.postId
        print(img)
        let imagesRef = storageRef.child(userid).child(postid)

        let spaceRef = imagesRef.child(img)
        
        self.imgPost.sd_setImage(with: spaceRef, placeholderImage: UIImage(named: "img_default")) { (image, error, typeCache, storageReference) in
            let imageSize = image?.size ?? .zero
            let newHeight = UIScreen.main.bounds.width * imageSize.height / UIScreen.main.bounds.width
            self.imgPost.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: newHeight)
            self.height4Images.constant = newHeight
            print(img)
            print(error)
        }
        
    }
}
