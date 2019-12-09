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
import FirebaseAuth

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var postHeight: NSLayoutConstraint!
    @IBOutlet weak var imgPost: UIImageView!
    @IBOutlet weak var btnLikes: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var cvPostImg: UICollectionView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var cvHashtags: UICollectionView!
    
    let storage = Storage.storage()
    let user = Auth.auth().currentUser
    
    var post: PostBE! {
        didSet{
            self.updatePosts()
        }
    }
    
    func updatePosts(){
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy HH:mma"
        
        let time = Date.init(timeIntervalSince1970: TimeInterval(integerLiteral: post.dateCreated?.seconds ?? 0))
        
        let now = df.string(from: time)
        txtDate.text = now
        txtUsername.text = post.authorDetails?.nickName
        txtMessage.text = post.message
        
        displayUserAvatar(userId: post.author ?? "")
        countLikes()
    }
    
    func displayUserAvatar(userId: String) {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child(userId)
        let spaceRef = imagesRef.child("perfil")
        self.imgAvatar.sd_setImage(with: spaceRef, placeholderImage: UIImage(named: "ic_person"))
    }
    
    func countLikes(){
        let likes = "\(self.post.likes?.count ?? 1)"
        print(likes)
        btnLikes.setTitle(likes, for: .normal)
        print(user?.uid)

        if (post.likes?.contains(user?.uid ?? ""))!{
            print("true")
            if #available(iOS 13.0, *) {
                btnLikes.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func displayPostImages(){
        // no funciona por que el imageview ya no existe reemplazado por el collectionview
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
extension HomeTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvPostImg {
            return post.pictures?.count ?? 0
        }else if collectionView == cvHashtags{
            return post.categories?.count ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cvPostImg{
            let cellIdentifier = "HomePostImageCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HomePostImageCollectionViewCell
            
            cell.userId = post.author
            cell.imgUrl = post.pictures?[indexPath.row]
            cell.layoutIfNeeded()
            
           
            self.postHeight.constant = collectionView.contentSize.height;
            return cell
        }else if collectionView == cvHashtags {
            let cellIdentifier = "CategoryHomeCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CategoryHomeCollectionViewCell
            let category = "#\(self.post.categories?[indexPath.row] ?? "")"
            cell.buttonHash.setTitle(category, for: .normal)
            cell.layoutIfNeeded()
            
            cell.contentView.frame = cell.bounds
            cell.contentView.autoresizingMask = [.flexibleLeftMargin,
                                                 .flexibleWidth,
                                                 .flexibleRightMargin,
                                                 .flexibleTopMargin,
                                                 .flexibleHeight,
                                                 .flexibleBottomMargin]
            self.postHeight.constant = collectionView.contentSize.height;
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == cvPostImg {
            return 0
        }else if collectionView == cvHashtags {
            return 8
        }
        return 0
    }
}
