//
//  NoteDetail-UI.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/24/24.
//

import Kingfisher
import FirebaseFirestore
import FirebaseAuth
import ImageSlideshow
import AVKit

extension NoteDetailVC{
    func setUI(){
        followBtn.layer.borderWidth = 1
        followBtn.layer.borderColor = mainColor.cgColor
        
        if isReadMyNote{
            followBtn.isHidden = true
            shareOrMoreBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            
        }
        showNote()
        showLike()
    }
    
    func showNote(){
        guard let noteData = note.data() else { return }
        
        //Note avatar
        if let authorRef = noteData[kAuthor] as? DocumentReference {
            // Fetch the author document
            authorRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let authorData = document.data()
                    
                    // Set the avatar image
                    if let avatarURLString = authorData?[kAvatar] as? String, let avatarURL = URL(string: avatarURLString) {
                        self.authorAvatarBtn.kf.setImage(with: avatarURL, for: .normal)
                    }
                    
                    // Set the nickname
                    if let nickName = authorData?[kNickName] as? String {
                        self.authorNickNameBtn.setTitle(nickName, for: .normal)
                    }
                } else {
                    print("Error fetching author data: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("Invalid author reference in note data")
        }
        
        if let videoURLString = noteData[kVideo] as? String, let videoURL = URL(string: videoURLString) {
            setupVideoPlayer(noteData: noteData, with: videoURL)
        } else {
            // Show images if there is no video
            showImages(noteData: noteData)
        }
        
        
        //noteTitle
        let noteTitle = note.getExactStringVal(kTitle)
        if noteTitle.isEmpty{
            titleLabel.isHidden = true
        }else{
            titleLabel.text = noteTitle
        }
        
        //note Text
        let noteText = note.getExactStringVal(kText)
        if noteText.isEmpty{
            textLabel.isHidden = true
        }else{
            textLabel.text = noteText
        }
        
        //        //noteTopic 待做话题
        //        let noteChannel = note.getExactStringVal(kChannelCol)
        //        let noteSubChannel = note.getExactStringVal(kSubChannelCol)
        //        channelBtn.setTitle(noteSubChannel.isEmpty ? noteChannel : noteSubChannel, for: .normal)
        
        //time of posting notes
        if let date = noteData[kDate] as? Timestamp{
            let dateValue = date.dateValue().formattedDate
            dateLabel.text = dateValue
        }
        
        
        //current user avatar
        if let user = Auth.auth().currentUser{
            let uid = user.uid
            
            db.collection("Users").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let avatarURL = document.data()?[kAvatar] as? String {
                        if let url = URL(string: avatarURL) {
                            self.avatarImageView.kf.setImage(with: url)
                        }
                    } else {
                        print("Avatar URL not found")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        likeCount = note.getExactIntVal(kLikedCount)
        currentLikeCount = likeCount
        
        favCount = note.getExactIntVal(kFavedCount)
        currentFavCount = favCount
        
        commentCount = note.getExactIntVal(kCommentCount)
    }
    
    func setupVideoPlayer(noteData: [String: Any], with url: URL) {
        let coverPhotoHeight = CGFloat(note.getExactDoubleVal(kCoverPhotoRatio) * screenRect.width)
        imageSlideShowHeight.constant = coverPhotoHeight
        
        if let coverPhotoURLString = noteData[kCoverPhoto] as? String, let coverPhotoURL = URL(string: coverPhotoURLString) {
            let coverPhoto = KingfisherSource(url: coverPhotoURL)
            self.imageSlideShow.setImageInputs([coverPhoto])}
        
        // Preload the video to check if it's ready to play
        preloadVideo(url: url) { isReady in
            DispatchQueue.main.async {
                if isReady {
                    let player = AVPlayer(url: url)
                    self.playerLayer = AVPlayerLayer(player: player)
                    self.playerLayer?.frame = self.imageSlideShow.bounds
                    self.playerLayer?.videoGravity = .resizeAspectFill
                    
                    // Remove previous player layer if any
                    if let sublayers = self.imageSlideShow.layer.sublayers {
                        for layer in sublayers where layer is AVPlayerLayer {
                            layer.removeFromSuperlayer()
                        }
                    }
                    
                    self.imageSlideShow.layer.addSublayer(self.playerLayer!)
                    player.play()
                    
                }
            }
        }
    }
    
    func showImages(noteData: [String: Any]) {
        let coverPhotoHeight = CGFloat(note.getExactDoubleVal(kCoverPhotoRatio) * screenRect.width)
        imageSlideShowHeight.constant = coverPhotoHeight
        
        if let coverPhotoURLString = note.get(kCoverPhoto) as? String, let coverPhotoURL = URL(string: coverPhotoURLString) {
            let coverPhoto = KingfisherSource(url: coverPhotoURL)
            
            // Fetching photo paths array
            if let photoPaths = note.get(kPhotos) as? [String] {
                var photoArr = photoPaths.compactMap { KingfisherSource(urlString: $0) }
                photoArr[0] = coverPhoto
                imageSlideShow.setImageInputs(photoArr)
            } else {
                imageSlideShow.setImageInputs([coverPhoto])
            }
        }
    }
    
    func preloadVideo(url: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVAsset(url: url)
        let keys = ["playable"]
        
        asset.loadValuesAsynchronously(forKeys: keys) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            
            switch status {
            case .loaded:
                completion(true)
            case .failed, .cancelled, .loading, .unknown:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
        
    }
    
    func listenForLikeCountUpdates() {
        let noteID = note.documentID
        
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

    
    func showLike(){
        self.likeBtn.setSelected(selected: isLikeFromWaterFallCell, animated: false)
    }
}
