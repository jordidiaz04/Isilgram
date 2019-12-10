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
import FirebaseFirestore
import CodableFirebase

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtMessage: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var postHeight: NSLayoutConstraint!
    @IBOutlet weak var btnLikes: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var cvPostImg: UICollectionView!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var cvHashtags: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var heighHastag: NSLayoutConstraint!
    
    @IBOutlet weak var imgIndicator: UIPageControl!
    let storage = Storage.storage()
    let db = Firestore.firestore()

    let user = Auth.auth().currentUser
    var currentPage = 0
    var comments: [CommentBE] = []
    
    var context: UIViewController!
    var post: PostBE! {
        didSet{
            self.updatePosts()
        }
    }
    
    
    @IBAction func giveLike(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if btnLikes.currentImage == UIImage(systemName: "hand.thumbsup.fill") {
                db.collection("posts").document(post.id!).updateData(["likes": FieldValue.arrayRemove([user?.uid])])
                btnLikes.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                let menos:Int? = (Int(btnLikes?.currentTitle ?? "1") ?? 1) - 1
                btnLikes.setTitle("\(menos ?? 0)", for: .normal)
            }
            else{
                db.collection("posts").document(post.id!).updateData(["likes": FieldValue.arrayUnion([user?.uid])])
                btnLikes.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                let mas:Int? = (Int(btnLikes?.currentTitle ?? "0") ?? 0) + 1
                btnLikes.setTitle("\(mas ?? 1)", for: .normal)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func seeComments(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let vc = storyboard.instantiateViewController(identifier: "CommentViewController") as! CommentViewController
            context.present(vc, animated: true, completion: nil)
            vc.idPost = post.id
        } else {
            // Fallback on earlier versions
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
        getComments(postId: post.id ?? "")
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
        }else{
            print("false")
            if #available(iOS 13.0, *) {
                btnLikes.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func getComments(postId: String){
        db.collection("comments").document(postId)
        .getDocument { (snapshot, error) in
        if let error = error{
            print("error: \(error)")
        } else {
            do {
                guard let data = snapshot?.data() else {
                    return
                }
                self.comments.removeAll()
                for item in data {
                    let comment = try! FirestoreDecoder().decode(CommentBE.self, from: item.value as! [String : Any])
                    self.comments.append(comment)
                }
                self.countComments()
                print(self.comments)
            } catch let error {
                print(error)
            }
        }
        }
    }
    
    func countComments(){
        btnComments.setTitle("\(comments.count)", for: .normal)
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
            
            let imgData = ImageBE(userId: post.author ?? "", imageUrl: post.pictures?[indexPath.row] ?? "")
            
            cell.imageBE = imgData
            cell.layoutIfNeeded()
                       
            self.postHeight.constant = collectionView.contentSize.height;
            if post.pictures?.count ?? 0 > 1 {
                self.imgIndicator.numberOfPages = post.pictures?.count ?? 0
            }

            heighHastag.constant = post.categories?.count == 0 ? 0 : 30
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            return cell
        }else if collectionView == cvHashtags {
            let cellIdentifier = "CategoryHomeCollectionViewCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CategoryHomeCollectionViewCell
            let category = "#\(self.post.categories?[indexPath.row] ?? "")"
            cell.buttonHash.setTitle(category, for: .normal)
            
            heighHastag.constant = collectionView.collectionViewLayout.collectionViewContentSize.height;
            
            cell.setNeedsLayout()
            cell.layoutIfNeeded()

            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cvHashtags {
            let frameWidth  = collectionView.frame.width
            let maxCellWidth = (frameWidth) / (7.0/6.0 + 6.0)
            let frameHeight  = collectionView.frame.height
            let maxCellHeight = frameHeight

            let cellEdge = maxCellWidth < maxCellHeight ? maxCellWidth : maxCellHeight

            return CGSize(width: cellEdge, height: cellEdge)
        }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
     {
        if scrollView == cvPostImg {
            let pageWidth = scrollView.frame.width
            self.currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            self.imgIndicator.currentPage = self.currentPage
        }

     }
    override func layoutSubviews() {
        cvHashtags.collectionViewLayout.collectionViewContentSize
    }

}
