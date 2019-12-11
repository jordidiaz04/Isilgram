//
//  CommentViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 12/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CodableFirebase

class CommentViewController: UIViewController {
    @IBOutlet weak var tblComment: UITableView!
    
    let db = Firestore.firestore()
    var idPost: String! = ""
    var comments: [CommentBE] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getComments(postId: idPost)
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
                
                self.tblComment.reloadData()
            } catch let error {
                print(error)
            }
        }
        }
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CommentTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
        
        cell.context = self
        cell.objCommentBE = self.comments[indexPath.row]
        
        return cell
    }
}
