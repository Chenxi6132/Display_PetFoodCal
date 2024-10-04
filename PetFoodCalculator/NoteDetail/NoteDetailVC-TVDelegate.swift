//
//  NoteDetailVC-TVDelegate.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/21/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let commentView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCommentViewID) as! CommentView
        let comment = comments[section]
        let commentAuthor = comment.getExactStringVal(kUser)
        let noteAuthor = note.getExactStringVal(kUID)
        
        commentView.comment = comment
        
        if commentAuthor == noteAuthor {
            commentView.authorLabel.isHidden = false
        }else{
            commentView.authorLabel.isHidden = true
        }
        
        let commentTap = UITapGestureRecognizer(target: self, action: #selector(commentTapped))
        commentView.tag = section
        commentView.addGestureRecognizer(commentTap)
        
        return commentView
    }
    
    //sectionFooter
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorLine = tableView.dequeueReusableHeaderFooterView(withIdentifier: kCommentSectionFooterViewID)
        
        return separatorLine
    }
    
    //user replies the reply
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let user = Auth.auth().currentUser?.uid{
            let reply = replies[indexPath.section].replies[indexPath.row]
            let replyAuthorUID = reply.getExactStringVal(kUser)
            print("the replyAuthorUID is \(replyAuthorUID)")

            var replyAuthorNickName = ""
 
            Task{
                do {
                    let userRef = try await db.collection("Users").document(replyAuthorUID).getDocument()
                    
                    // Retrieve the nickname
                    if let nickname = userRef.data()?[kNickName] as? String {
                        replyAuthorNickName = nickname
                        print("In Task: The reply author name is \(replyAuthorNickName)")
                    } else {
                        print("Nickname not found.")
                    }
                    
                    //current user tap self reply
                    if reply.getExactStringVal(kUser) == user {
                        let replyText = reply.getExactStringVal(kReplyComment)
                        
                        let alert = UIAlertController(title: nil, message: "Your Reply: \(replyText)", preferredStyle: .actionSheet)
                        
                        let subReplyAction = UIAlertAction(title: "Reply", style: .default) { _ in

                            self.prepareForReply(replyAuthorNickName, indexPath.section, replyAuthorUID)
                        }
                        
                        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
                            UIPasteboard.general.string = replyText
                        }
                        
                        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                            self.delReply(reply, indexPath)
                            //self.DelComment(comment, section)
                        }
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        alert.addAction(subReplyAction)
                        alert.addAction(copyAction)
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)
                        
                        present(alert, animated: true)
                    }else{//current user tap others reply
                        self.prepareForReply(replyAuthorNickName, indexPath.section, replyAuthorUID)
                    }
                    
                } catch {
                    print("Error fetching document: \(error.localizedDescription)")
                }
            }
            
        }else{
            showLoginHUD()
        }
    }
}

extension NoteDetailVC{
    @objc private func commentTapped(_ tap: UITapGestureRecognizer){
        if let user = Auth.auth().currentUser?.uid{
            guard let section = tap.view?.tag else {return}
            let comment = comments[section]
            var commentAuthorNickName: String
            
            let commentAuthor = comment.getExactStringVal(kUser)
            if let commentView = tableView.headerView(forSection: section) as? CommentView {
                commentAuthorNickName = commentView.replyToNickName ?? "Unknown"
                print("Nick name is \(commentAuthorNickName)")
                
                if commentAuthor == user {
                    let commentText = comment.getExactStringVal(kComment)
                    
                    let alert = UIAlertController(title: nil, message: "Your Comments: \(commentText)", preferredStyle: .actionSheet)
                    
                    let replyAction = UIAlertAction(title: "Reply", style: .default) { _ in
                        self.prepareForReply(commentAuthorNickName, section)
                    }
                    
                    let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
                        UIPasteboard.general.string = commentText
                    }
                    
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                        self.DelComment(comment, section)
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    
                    alert.addAction(replyAction)
                    alert.addAction(copyAction)
                    alert.addAction(deleteAction)
                    alert.addAction(cancelAction)
                    
                    present(alert, animated: true)
                }else{
                    //reply action only
                    prepareForReply(commentAuthorNickName, section)
                }
            }
        }else{
            showLoginHUD()
        }
    }
}


