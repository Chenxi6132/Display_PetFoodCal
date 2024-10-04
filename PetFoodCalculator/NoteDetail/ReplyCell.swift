//
//  ReplyCell.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/6/24.
//

import FirebaseFirestore
import Kingfisher

class ReplyCell: UITableViewCell {
    let db = Firestore.firestore()
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var replyTextLabel: UILabel!
    @IBOutlet weak var showAllReplyBtn: UIButton!
    
    var reply: DocumentSnapshot?{
        didSet{
            guard let reply = reply else {return}
            let replyData = reply.data()
            
            let replyUser = reply.getExactStringVal(kUser)
            print("Replycomments user is \(replyUser) ")
            db.collection("Users").document(replyUser).getDocument { (document, error) in
                if let document = document, document.exists{
                    if let avatarURL = document.data()?[kAvatar] as? String {
                        if let url = URL(string: avatarURL) { self.avatarImageView.kf.setImage(with: url)}
                    }
                    if let nickName = document.data()?[kNickName] as? String{
                        self.nickNameLabel.text = nickName
                    }
                }
            }
            
            //replies and date
            let date = replyData![kDate] as? Timestamp
            let dateText = date == nil ? "Just Now" : date!.dateValue().formattedDate
            let replytext = reply.getExactStringVal(kReplyComment).spliceAtrrStr(dateText)
            
//            let replyToUser = reply.getExactStringVal(kReplyToUser)

//            guard !replyToUser.isEmpty else {
//                print("Error: replyToUser is empty, skipping Firestore request.")
//                return
//            }
            
            let replyToNickName = reply.getExactStringVal(kSubReplyToAuthorNicName)
            let replyToText = "Reply ".toAttrStr()
            let nickName = replyToNickName.toAttrStr(14, .secondaryLabel)
            print("pinjie lide nickname \(nickName)")
            let colon = ": ".toAttrStr()
            
            replyToText.append(nickName)
            replyToText.append(colon)
            
            replytext.insert(replyToText, at: 0)
            
            replyTextLabel.attributedText = replytext
            
        }
    }
    

}
