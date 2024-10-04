//
//  NoteDetailVC-DelComment.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/1/24.
//

import FirebaseCore
import FirebaseFirestore

extension NoteDetailVC{
    func DelComment(_ comment: DocumentSnapshot, _ section: Int){
        showDelAlert(for: "Reply") { _ in
            
            //firebase database
            comment.reference.delete { _ in }
            self.updateCommentCount(by: -1)
            
            //local memory
            self.comments.remove(at: section)
            
            //UI -- reloadData can update index under datasource
            self.tableView.reloadData()
        }
    }
}
