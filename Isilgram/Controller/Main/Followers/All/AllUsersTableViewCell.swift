//
//  AllUsersTableViewCell.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/14/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseUI

class AllUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var lblFullName: CSMLabel!
    @IBOutlet weak var lblEmail: CSMLabel!
    @IBOutlet weak var lblBirthDate: CSMLabel!
    @IBOutlet weak var btnFollow: CSMButton!
    
    //MARK: Variables and Components
    let user = Auth.auth().currentUser
    
    let dbFollowers = Firestore.firestore().collection(Constant.dbRefFollowers)
    
    let stgUser = Storage.storage().reference()
    
    var context: UIViewController!
    
    var objUserBE: UserBE!{
        didSet{
            self.updateData()
        }
    }

    
    //MARK: Override Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //MARK: IBAction Functions
    @IBAction func follow(_ sender: Any) {
        self.followUser()
    }
    
    
    //MARK: Created Functions
    func updateData(){
        self.ivPhoto.clipsToBounds = true
        
        self.lblFullName.text = "\(self.objUserBE.fullName)"
        self.lblEmail.text = "Email: \(self.objUserBE.email)"
        self.lblBirthDate.text = "Cumpleaños: \(self.objUserBE.birthDate)"
        
        let refStorage = stgUser.child(objUserBE.id).child("perfil")
        self.ivPhoto.sd_setImage(with: refStorage)
    }
    
    func followUser() {
        let data: [String: Any] = [ "\(objUserBE.id)": true ]
         
        dbFollowers.document(user!.uid).updateData(data) { (err) in
            if let err = err {
                Function.showAlertError(context: self.context, err: err)
            }
        }
    }
}
