//
//  CommentView.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/21/24.
//

import UIKit
import FirebaseFirestore

class CommentView: UITableViewHeaderFooterView {
    let db = Firestore.firestore()
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    var comment: DocumentSnapshot?{
        didSet{
            guard let comment = comment else {return}
            let commentData = comment.data()
            
            let commentUser = comment.getExactStringVal(kUser)
            print("comments user is \(commentUser) ")
            //get avatar and nickName
            db.collection("Users").document(commentUser).getDocument { (document, error) in
                if let document = document, document.exists{
                    if let avatarURL = document.data()?[kAvatar] as? String {
                        if let url = URL(string: avatarURL) { self.avatarImageView.kf.setImage(with: url)}
                    }
                    if let nickName = document.data()?[kNickName] as? String{
                        self.nickNameLabel.text = nickName
                    }
                }
            }
            
            // get comment and date
            let commentText = comment.getExactStringVal(kComment)
            print("commentText is  \(commentText)")
            
            let date = commentData![kDate] as? Timestamp
            let dateText = date == nil ? "just now" : date!.dateValue().formattedDate
            
            commentTextLabel.attributedText = commentText.spliceAtrrStr(dateText)
            
        }
        
    }
        
        
        var replyToNickName: String? {
            return nickNameLabel.text
        }

}
