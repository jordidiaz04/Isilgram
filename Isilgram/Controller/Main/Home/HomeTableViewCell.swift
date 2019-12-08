//
//  HomeTableViewCell.swift
//  Isilgram
//
//  Created by Autopsia on 12/7/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseUI

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var postHeight: NSLayoutConstraint!
    @IBOutlet weak var imgPost: UIImageView!
    
    let storage = Storage.storage()
    
    var post: PostBE! {
        didSet{
            self.updatePosts()
        }
    }
    
    func updatePosts(){
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy hh:mm"
        
        let time = Date.init(timeIntervalSince1970: TimeInterval(integerLiteral: post.dateCreated?.seconds ?? 0))
        
        let now = df.string(from: time)
        
        txtUsername.text =  now //post.authorDetails?.nickName
        txtMessage.text = post.message
        
        displayUserAvatar(userId: post.author ?? "")
        displayPostImages()
    }
    
    func displayUserAvatar(userId: String) {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(userId)
        let spaceRef = imagesRef.child("perfil")
        self.imgAvatar.sd_setImage(with: spaceRef, placeholderImage: UIImage(named: "ic_person"))
    }
    
    func displayPostImages(){
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(post.author ?? "")
        let img = post.pictures?[0] ?? ""
        print(img)
        let spaceRef = imagesRef.child("perfil")
        
        self.imgPost.sd_setImage(with: spaceRef, placeholderImage: UIImage(named: "logo")) { (image, error, typeCache, storageReference) in
            let imageSize = image?.size ?? .zero
            let newHeight = self.imgPost.frame.width * imageSize.height / imageSize.width
            self.imgPost.frame = CGRect(x: 0, y: 0, width: self.imgPost.frame.width, height: newHeight)
            self.postHeight.constant = newHeight
            print(img)
                }
        
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
