//
//  NoteDetail-LoadData.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/22/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC{
    func getComments(){
        showLoadHUD()
        let noteID = note.getExactStringVal(kNoteID)
        print("noteID is \(noteID)")
        
        //待做: 分页加载
        db.collection(KUserCommentTable)
            .whereField(kNote, isEqualTo: noteID)
            .order(by: kDate, descending: false)
            .getDocuments { snapshot, error in
                self.hideLoadHUD()
                if let error = error {
                    print("Error getting comment documents: \(error.localizedDescription)")
                    return
                }
                
                if let document = snapshot?.documents {
                    print("The number of documents is \(document.count)")
                    self.comments = document
                    self.getReplies()

                } else {
                    print("Like Document not found")
                }
            }

        
    }
    
    
    func getReplies(){
        //print("the comment get from userReply table is \(comment.getExactDoubleVal(kComment))")
        var repliesDic: [Int: [DocumentSnapshot]] = [:]
        let group = DispatchGroup()
        for (index, comment) in comments.enumerated(){
            
            if comment.getExactBoolDefaultT(kHasReply){ //has reply
                group.enter()
                db.collection(kUserReplyTable)
                    .whereField(kComment, isEqualTo: comment.getExactStringVal(kComment))
                    .order(by: kDate, descending: false)
                    .getDocuments { snapshot, error in
                        defer {group.leave()} // Ensure `leave()` is called at the end of the block
                        if let error = error{
                            print("Error getting replies document: \(error.localizedDescription) ")
                        }
                        
                        if let document = snapshot?.documents {
                            if document.isEmpty{
                                comment.setValue(false, forKey: kHasReply)
                            }
                            repliesDic[index] = document
                        }else{
                            repliesDic[index] = []
                        }
                        
                    }
            }else{
                //no reply
                repliesDic[index] = []
            }
        }
        group.notify(queue: .main) {
            self.replies = repliesDic.sorted{ $0.key < $1.key }.map{ExpandableReplies(replies: $0.value)}
                
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    func getFav(){
        let noteID = note.getExactStringVal(kNoteID)
        if let user = Auth.auth().currentUser{
            db.collection(kUserFavTable)
                .whereField(kNote, isEqualTo: noteID)
                .whereField(kUser, isEqualTo: user.uid)
                .getDocuments { snapshot, error in
                    if let error = error{
                        print("Error getting replies document: \(error.localizedDescription) ")
                    }
                    
                    if let _ = snapshot?.documents.first {
                        DispatchQueue.main.async{
                            self.favBtn.setSelected(selected: true, animated: false)
                        }
                    }
                    
                }
        }
    }
    
    
}
