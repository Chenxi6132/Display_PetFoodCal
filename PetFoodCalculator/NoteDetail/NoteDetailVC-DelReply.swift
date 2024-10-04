//
//  NoteDetailVC-DelReply.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/19/24.
//

import FirebaseFirestore

extension NoteDetailVC{
    func delReply(_ reply: DocumentSnapshot, _ indexPath: IndexPath){
        
        showDelAlert(for: "Reply") { _ in
            //firebase database
            reply.reference.delete { _ in }
            self.updateCommentCount(by: -1)
            
            //local memory
            self.replies[indexPath.section].replies.remove(at: indexPath.row)
            
            //UI -- reloadData can update index under datasource
            self.tableView.reloadData()
        }
    }
}
