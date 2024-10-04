//
//  WaterFallCell.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/17/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Kingfisher


class WaterFallCell: UICollectionViewCell {
    let db = Firestore.firestore()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    var isLikeFromNoteDetailVC = false
    
    var likeCount = 0{
        didSet{
            likeBtn.setTitle(likeCount.formattedStr, for: .normal)
        }
    }
    
    var currentLikeCount = 0 //check how many time that user hit fave button in 1 sec
    
    var isLike: Bool { likeBtn.isSelected }
    
    var note: DocumentSnapshot?{
        didSet{
            
            guard let note = note, let noteData = note.data() else {return}
            
            // Set title
            titleLabel.text = note.getExactStringVal(kTitle)
            
            // Set cover photo
            if let coverPhotoURL = note.getImageURL(from: noteData, col: kCoverPhoto, .coverPhoto) {
                imageView.kf.setImage(with: coverPhotoURL, options: [.transition(.fade(0.2))])
            }
            
            // Set like count
            likeCount = note.getExactIntVal(kLikedCount)
            currentLikeCount = likeCount
            
            // Set the avatar image and nickname
            if let authorData = noteData[kAuthor] as? DocumentReference {
                // Fetch the author document
                authorData.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let authorData = document.data()
                        
                        // Set the avatar image
                        if let avatarURLString = authorData?[kAvatar] as? String, let avatarURL = URL(string: avatarURLString) {
                            self.avatarImageView.kf.setImage(with: avatarURL)
                        }
                        
                        // Set the nickname
                        if let nickName = authorData?[kNickName] as? String {
                            self.nickNameLabel.text = nickName
                        }
                    } else {
                        print("Error fetching author data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
                
            }
            
            if let user = Auth.auth().currentUser{
                let noteID = note.getExactStringVal(kNoteID)
                
                db.collection(kUserLikeTable)
                    .whereField(kUser, isEqualTo: user.uid)
                    .whereField(kNote, isEqualTo: noteID)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error getting documents: \(error.localizedDescription)")
                            return
                        }
                        
                        // Ensure you're updating the likeBtn corresponding to the correct note
                        if let _ = snapshot?.documents.first {
                            DispatchQueue.main.async {
                                self.likeBtn.isSelected = true
                            }
                        }
                    }
            }
            
            listenForLikeCountUpdates()
        }
    }
    

    
    func listenForLikeCountUpdates() {
        let noteID = note!.documentID
        
        db.collection("Notes").document(noteID).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let self = self, let document = documentSnapshot, document.exists else {
                if let error = error {
                    print("Error listening for like count updates: \(error.localizedDescription)")
                }
                return
            }
            
            if let updatedLikeCount = document.get(kLikedCount) as? Int {
                self.likeCount = updatedLikeCount
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let icon = UIImage(systemName: "heart.fill")?.withTintColor(mainColor, renderingMode: .alwaysOriginal)
        likeBtn.setImage(icon, for: .selected)
    }
    
    @IBAction func like(_ sender: Any) {
        if let _ = Auth.auth().currentUser{
            //UI
            likeBtn.isSelected.toggle()
            isLike ? (likeCount += 1) : (likeCount -= 1)
            
            //Database
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(likeBtnTappedWhenLogin), object: nil)
            perform(#selector(likeBtnTappedWhenLogin), with: nil, afterDelay: 1)
            
        }else{
            showGlobalTextHUD("Please LogIn")
        }
        
    }
    
    

    
}
