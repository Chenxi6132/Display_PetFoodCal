//
//  NoteDetailVC-PostComment.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/1/24.
//

import FirebaseAuth
import FirebaseFirestore

extension NoteDetailVC{
    func postComment(){
        let user = Auth.auth().currentUser!
        let noteID = note.getExactStringVal(kNoteID)
        let commentID = UUID().uuidString
        let commentData: [String: Any] = [
            kCommentID:commentID,
            kUser: user.uid,
            kNote: noteID,
            kHasReply: false,
            kComment: textView.unwrappedText,
            kDate: Date()
        ]
    

        let commentRef = db.collection(KUserCommentTable).document(commentID)
        commentRef.setData(commentData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Post Comment Failure: \(error)")
            } else {
                DispatchQueue.main.async { self.showTextHUD("Post Comment Successfully") }
                
                commentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // Insert the document snapshot into the array
                        self.comments.insert(document, at: 0)
                    } else {
                        print("Document does not exist or error occurred: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    
                    // Notify the UI to refresh
                    self.tableView.performBatchUpdates {
                        self.tableView.insertSections(IndexSet(integer: 0), with: .automatic)
                    }
                    self.updateCommentCount(by: 1)
                    
                }
            }
        }
    }
}
