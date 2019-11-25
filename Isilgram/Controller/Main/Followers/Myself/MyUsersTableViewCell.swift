//
//  MyUsersTableViewCell.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/15/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseUI

class MyUsersTableViewCell: UITableViewCell {
    @IBOutlet weak var ivPhoto: CSMImageView!
    @IBOutlet weak var lblFullName: CSMLabel!
    @IBOutlet weak var lblEmail: CSMLabel!
    @IBOutlet weak var lblBirthDate: CSMLabel!
    @IBOutlet weak var btnUnfollow: CSMButton!
    
    
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
    @IBAction func unfollow(_ sender: Any) {
        let data: [String: Any] = [ "\(objUserBE.id)": FieldValue.delete() ]
         
        dbFollowers.document(user!.uid).updateData(data) { (err) in
            if let err = err {
                Function.showAlertError(context: self.context, err: err)
            }
        }
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
}
