//
//  MyFollowersViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/14/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class MyFollowersViewController: UIViewController {
    @IBOutlet weak var tblUsers: UITableView!
    
    
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    var dbFollowers: CollectionReference!
    var arrayUsers = [UserBE]()
    var arrayFollowers = [String]()
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        dbFollowers = Firestore.firestore().collection(Constant.dbRefFollowers)
        
        self.listFollowers()
    }
    
    
    //MARK: Created Functions
    func listFollowers() {
        let uid = Auth.auth().currentUser?.uid
        
        dbFollowers.document(uid!).addSnapshotListener { (snapshot, err) in
            if let err = err {
                Function.showAlertError(context: self, err: err)
            }
            else {
                guard let data = snapshot?.data() else {
                    return
                }
                
                self.arrayUsers.removeAll()
                self.arrayFollowers.removeAll()
                
                for item in data {
                    self.arrayFollowers.append(item.key)
                }
                self.listAllUsers()
            }
        }
    }
    func listAllUsers() {
        if arrayFollowers.count > 0 {
            for item in arrayFollowers {
                dbUsers.document(item).getDocument { (document, err) in
                    if let err = err {
                        Function.showAlertError(context: self, err: err)
                    }
                    else {
                        guard let document = document else {
                            return
                        }
                        
                        var objUserBE = try! FirebaseDecoder().decode(UserBE.self, from: document.data()!)
                        objUserBE.id = document.documentID
                        self.arrayUsers.append(objUserBE)
                        self.listDataTable()
                    }
                }
            }
        }
        else {
            self.tblUsers.reloadData()
        }
    }
    func listDataTable() {
        if arrayUsers.count == arrayFollowers.count {
            self.tblUsers.reloadData()
        }
    }
}

extension MyFollowersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayUsers.count
    }    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MyUsersTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MyUsersTableViewCell
        
        cell.context = self
        cell.objUserBE = arrayUsers[indexPath.row]
        
        return cell
    }
}
