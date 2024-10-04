//
//  NoteDetailVC-Helper.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/18/24.
//

import FirebaseAuth
import FirebaseFirestore

extension NoteDetailVC{
    func comment(){
        if let _ = Auth.auth().currentUser{
            showTextView()
        }else{
            showLoginHUD()
        }
    }
    
    func prepareForReply(_ nickname: String, _ section: Int, _ isSubReply: String? = nil, _ subReplyAuthor: String? = nil){
        showTextView(true, "reply to \(nickname)", isSubReply, nickname)
        commentSection = section
    }
    
    func showTextView(_ isReply: Bool = false, _ textViewPH : String = kNoteCommentPH, _ isSubReply: String? = nil, _ nickname: String? = nil ){
        //reset
        self.isReply = isReply
        textView.placeholder = textViewPH
        self.isSubReply = isSubReply
        self.subReplyToAuthor = nickname
        
        //UI
        textView.becomeFirstResponder()
        textViewBarView.isHidden = false
    }
    
    //after post comment or reply, need to reset
    func hideAndResetTextView(){
        textView.resignFirstResponder()
        textView.text = "" //reset
    }
    
}

extension NoteDetailVC{
    func showDelAlert(for name: String, confirmHandler: ((UIAlertAction) -> ())? ){
        let alert = UIAlertController(title: "Prompt", message: "Delete the \(name)?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Cancel", style: .cancel)
        let action2 = UIAlertAction(title: "Confirm", style: .default, handler: confirmHandler)
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true)
    }
    
    func updateCommentCount(by offset: Int){
        let CommentRef = db.collection("Notes").document(note.getExactStringVal(kNoteID))
        CommentRef.updateData([kCommentCount : FieldValue.increment(Int64(offset))])
        
        self.commentCount += offset
    }
}
