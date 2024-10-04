//
//  NoteDetailVC-TVDataSource.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/21/24.
//

import Foundation

extension NoteDetailVC: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        print("total comments is \(comments.count)")
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let replyCount = replies[section].replies.count
        
        //replies[section].isExpanded default value is true
        if replyCount > 1 && !replies[section].isExpanded {
            return 1
        }else{
            return replyCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReplyCellID, for: indexPath) as! ReplyCell
        
        let reply = replies[indexPath.section].replies[indexPath.row]
        
        cell.reply = reply
        
        let replyAuthor = reply.getExactStringVal(kUser)
        let noteAuthor = note.getExactStringVal(kUID)
        
        if replyAuthor == noteAuthor{
            cell.authorLabel.isHidden = false
        }else{
            cell.authorLabel.isHidden = true
        }
        
        //if replies greate than one, need to show replies hidden button
        let replyCount = replies[indexPath.section].replies.count
        if replyCount > 1, !replies[indexPath.section].isExpanded {
            cell.showAllReplyBtn.isHidden = false
            cell.showAllReplyBtn.setTitle("Expand \(replyCount-1) replies", for: .normal)
            cell.showAllReplyBtn.tag = indexPath.section
            cell.showAllReplyBtn.addTarget(self, action: #selector(showAllReply), for: .touchUpInside)
        }else{
            cell.showAllReplyBtn.isHidden = true
        }
        
        
        return cell
    }
}


extension NoteDetailVC{
    @objc private func showAllReply(sender: UIButton){
        let section = sender.tag
        replies[section].isExpanded = true
        tableView.performBatchUpdates {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }

    }
}
