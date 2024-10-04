//
//  NoteDetailVC-ShareOrMore.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/18/24.
//

import Foundation
extension NoteDetailVC{
    func shareOrMore(){
        if isReadMyNote{
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let shareAction = UIAlertAction(title: "Share", style: .default) { _ in /*share action*/ }
            let editAction = UIAlertAction(title: "Edit", style: .default) { _ in self.editNote() }
            let delAction = UIAlertAction(title: "Delete", style: .default) { _ in self.delNote() }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            alert.addAction(shareAction)
            alert.addAction(editAction)
            alert.addAction(delAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }else{
            //share action
        }
    }
}
