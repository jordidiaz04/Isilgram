//
//  HomeViewController.swift
//  Isilgram
//
//  Created by Jordi Díaz Robles on 11/10/19.
//  Copyright © 2019 pe.jordi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import CodableFirebase

class HomeViewController: UIViewController {
    var posts = [PostBE]()
    let db = Firestore.firestore()

    @IBOutlet weak var tvPrincipal: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        Function.removeLastestViews(context: self)
        tvPrincipal.rowHeight = UITableView.automaticDimension
        tvPrincipal.estimatedRowHeight = 500
        getPosts()
    }
    
    func getPosts(){
        db.collection("posts")
            .getDocuments { (snapshot, error) in
            if let error = error{
                print("error: \(error)")
            } else {
                for document in snapshot!.documents {
                    print(document)
                    var post = PostBE()
                    do {
                        post = try! FirestoreDecoder().decode(PostBE.self, from: document.data())
                        if post != nil.self {
                            self.getUserName(id: post.author ?? "", post: post)
                            print(self.posts)
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
            }
    }
    
    func getUserName(id: String, post: PostBE){
        db.collection("users").document(id)
            .getDocument { (snapshot, error) in
            if let error = error{
                print("error: \(error)")
            } else {
                var user = UserBE()
                do {
                    guard let data = snapshot?.data() else {
                        return
                    }
                    user = try! FirestoreDecoder().decode(UserBE.self, from: data)
                    if user != nil.self {
                        var post = post
                        post.authorDetails = user
                        self.posts.append(post)
                        self.tvPrincipal.reloadData()
                        print(self.posts)
                    }
                } catch let error {
                    print(error)
                }
            }
            }
    }
}
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "HomeTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
        cell.post = self.posts[indexPath.row]
        self.tvPrincipal.sizeToFit()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
