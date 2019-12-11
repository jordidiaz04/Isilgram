//
//  CommentTableViewCell.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 12/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase
import FirebaseUI

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var lblUsername: CSMLabel!
    @IBOutlet weak var lblMessage: CSMLabel!
    @IBOutlet weak var lblDate: CSMLabel!
    
    let db = Firestore.firestore()
    var stgUser: StorageReference! = Storage.storage().reference()
    
    var context: UIViewController!
    var objCommentBE: CommentBE!{
        didSet{
            self.updateData()
        }
    }
    
    func updateData() {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy HH:mma"
        let time = Date.init(timeIntervalSince1970: TimeInterval(integerLiteral: objCommentBE.dateCreated?.seconds ?? 0))
        let date = df.string(from: time)
        
        lblMessage.text = objCommentBE.message
        lblDate.text = date
        getAuthorInformation()
        
    }
    func getAuthorInformation() {
        db.collection("users").document(objCommentBE.author!).addSnapshotListener { (documentSnapshot, err) in
            if err == nil {
                guard let document = documentSnapshot else {
                    return
                }
                guard let data = document.data() else {
                    return
                }
                
                let objUserBE = try! FirestoreDecoder().decode(UserBE.self, from: data)
                self.lblUsername.text = objUserBE.nickName
                self.showPhoto(imageName: objUserBE.namePhoto)
            }
        }
    }
    func showPhoto(imageName: String) {
        let refPhoto = stgUser.child(imageName).child("perfil")
        ivPhoto.sd_setImage(with: refPhoto, placeholderImage: UIImage(named: "img_default"))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
