//
//  NoteDetailVC-EditNote.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/18/24.
//

import Foundation
import FirebaseFirestore
import Kingfisher
extension NoteDetailVC{
    func editNote(){
        var photos: [UIImage] = []
        if let coverPhotoPath = note.get(kCoverPhoto) as? String, let coverPhoto = ImageCache.default.retrieveImageInMemoryCache(forKey: coverPhotoPath){
            photos.append(coverPhoto)
        }
        
        if let photoPaths = note.get(kPhotos) as? [String]{
            let otherPhotos = photoPaths.compactMap{ImageCache.default.retrieveImageInMemoryCache(forKey:$0)}
            photos.append(contentsOf: otherPhotos)
        }
        
        //handle video from firebase using kingfisher  note.get(kVideo)
        
        let vc = storyboard!.instantiateViewController(withIdentifier: kNoteEditVCID) as! NoteEditVC
        vc.note = note
        vc.photos = photos
        vc.videoURL = nil
        showLoadHUD()
        vc.updateNoteFinished = {noteID in
            let noteRef = self.db.collection("Notes").document(noteID)
            noteRef.getDocument { document, error in
                 if let error = error {
                     DispatchQueue.main.async {
                         self.showTextHUD("Some Errors Happen, Please Try Again")}
                     print("Error getting document: \(error.localizedDescription)")
                     return
                 }
                 self.hideLoadHUD()
                 if let document = document, document.exists {
                     
                     self.note = document  //database
                     self.showNote() //UI
                 } else {
                     DispatchQueue.main.async {
                         self.showTextHUD("Note Not Exist")}
                 }
             }
        }
        
        present(vc, animated: true)
    }
}

