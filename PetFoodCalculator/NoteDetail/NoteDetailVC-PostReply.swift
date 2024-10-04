//
//  NoteDetailVC-PostReply.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/1/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC{
    func postReply(){
        let comment = comments[commentSection]
        
        let user = Auth.auth().currentUser!
        let noteID = note.getExactStringVal(kNoteID)
        let replyCommentID = UUID().uuidString
        var replyCommentData: [String: Any] = [
            kReplyComment: textView.unwrappedText,
            kUser: user.uid,
            kNote: noteID,
            kComment: comment.getExactStringVal(kComment),
            kDate: Date()
        ]
        
        if let isSubReply = isSubReply {
            replyCommentData[kReplyToUser] = isSubReply
            replyCommentData[kSubReplyToAuthorNicName] = subReplyToAuthor
        }
        
        
        print("staring write data in to reply")
        let replyCommenttRef = db.collection(kUserReplyTable).document(replyCommentID)
        replyCommenttRef.setData(replyCommentData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Post reply Failure: \(error)")
            } else {
                var commentData = comment.data()
                if let hasReply = commentData?[kHasReply] as? Bool, hasReply != true{
                    commentData?.updateValue(true, forKey: kHasReply)
                }
                
                DispatchQueue.main.async { self.showTextHUD("Post reply Successfully") }
                
                replyCommenttRef.getDocument { (document, error) in
                    //Note detail UI comments number
                    self.updateCommentCount(by: 1)
                    
                    if let document = document, document.exists {
                        // Insert the document snapshot into the array
                        self.replies[self.commentSection].replies.append(document)
                    } else {
                        print("Document does not exist or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    
                    // Notify the UI to refresh
                    if self.replies[self.commentSection].isExpanded {
                        self.tableView.performBatchUpdates {
                            self.tableView.insertRows(at: [IndexPath(row: self.replies[self.commentSection].replies.count - 1, section: self.commentSection)], with: .automatic)
                        }
                    }else {
                        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.commentSection)) as! ReplyCell
                        cell.showAllReplyBtn.setTitle("Expand \(self.replies[self.commentSection].replies.count - 1) replies", for: .normal)
                    }
                }
            }
        }
        
        
        
        
    }
}
