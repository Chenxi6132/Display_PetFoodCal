//
//  NoteDetailVC-Follow.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/17/24.
//

import FirebaseFirestore
import FirebaseAuth

extension NoteDetailVC{
    func follow(){
        if let _ = Auth.auth().currentUser{
            //UI
            followBtn.isSelected.toggle()
            isFollow ? (followCount += 1) : (followCount -= 1)
            //data
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FollowBtnTappedWhenLogin), object: nil)
            perform(#selector(FollowBtnTappedWhenLogin), with: nil, afterDelay: 1)
            
        }else{
            showLoginHUD()
        }
    }
    
    @objc private func FollowBtnTappedWhenLogin() {
        if followCount != currentFollowCount{
            // 去关注
            let user = Auth.auth().currentUser!
            //被关注
            let FollowedUser = note.getExactStringVal("uid")
            let offset = isFollow ? 1 : -1
            currentFollowCount += offset
            print(isFollow)
            if isFollow{
                db.collection(kUserFollowTable).document(UUID().uuidString).setData([
                    kUser: user.uid,
                    kFUser: FollowedUser
                ])
                
                //increment following count in User table
                let UserRef = db.collection("Users").document(user.uid)
                UserRef.updateData([kFollowingCount : FieldValue.increment(Int64(1))])
                
                //increment follower count in User table
                let FollowedUserRef = db.collection("Users").document(FollowedUser)
                FollowedUserRef.updateData([kFollowerCount: FieldValue.increment(Int64(1))])
                
            }else{
                db.collection(kUserFollowTable)
                    .whereField(kUser, isEqualTo: user.uid)
                    .whereField(kFUser, isEqualTo: FollowedUser)
                    .getDocuments { snapshot, error in
                        if let error = error { print("Error getting documents: \(error.localizedDescription)")
                            return }
                        
                        if let document = snapshot?.documents.first {
                            document.reference.delete { error in
                                if let error = error {
                                    print("Error deleting document: \(error.localizedDescription)")
                                } else {
                                    print("Successfully Unfollow Note")
                                }
                            }
                        } else {
                            print("Follow Document not found")
                        }
                    }
                //decrement following count in User table
                let UserRef = db.collection("Users").document(user.uid)
                UserRef.updateData([kFollowingCount : FieldValue.increment(Int64(-1))])
                
                //decrement follower count in User table
                let FollowedUserRef = db.collection("Users").document(FollowedUser)
                FollowedUserRef.updateData([kFollowerCount: FieldValue.increment(Int64(-1))])
                
            }
        }
    }
}
