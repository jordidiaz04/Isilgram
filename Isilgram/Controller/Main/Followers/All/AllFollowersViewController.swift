//
//  AllFollowersViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/14/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase

class AllFollowersViewController: UIViewController {
    @IBOutlet weak var tblUsers: UITableView!
    
    
    //MARK: Variables and Components
    var dbUsers: CollectionReference!
    
    var dbFollowers: CollectionReference!
    
    var arrayUsers = [UserBE]()
    
    var arrayFollowers = [String]()
    
    
    //MARK: Override Functions
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        dbUsers = Firestore.firestore().collection(Constant.dbRefUser)
        dbFollowers = Firestore.firestore().collection(Constant.dbRefFollowers)
        self.listAllUsers()
    }
    
    
    //MARK: IBAction Functions
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Created Functions
    func listAllUsers() {
        dbUsers.getDocuments { (snapshot, err) in
            if let err = err {
                Function.showAlertError(context: self, err: err)
            }
            else {
                self.arrayUsers.removeAll()
                
                for document in snapshot!.documents {
                    var objUserBE = try! FirebaseDecoder().decode(UserBE.self, from: document.data())
                    objUserBE.id = document.documentID
                    if objUserBE.id != Auth.auth().currentUser?.uid {
                        self.arrayUsers.append(objUserBE)
                    }
                }
                self.listFollowers()
            }
        }
    }
    
    func listFollowers() {
        let uid = Auth.auth().currentUser?.uid
        
        dbFollowers.document(uid!).addSnapshotListener { (snapshot, err) in
            if let err = err {
                Function.showAlertError(context: self, err: err)
            }
            else {
                if let data = snapshot!.data() {
                    self.arrayFollowers.removeAll()
                    
                    for item in data {
                        self.arrayFollowers.append(item.key)
                    }
                }
                self.listDataTable()
            }
        }
    }
    
    func listDataTable() {
        for item in arrayFollowers {
            arrayUsers = arrayUsers.filter { $0.id != item }
        }
        
        self.tblUsers.reloadData()
    }
}

extension AllFollowersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AllUsersTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AllUsersTableViewCell
        
        cell.context = self
        cell.objUserBE = arrayUsers[indexPath.row]
        
        return cell
    }
}
