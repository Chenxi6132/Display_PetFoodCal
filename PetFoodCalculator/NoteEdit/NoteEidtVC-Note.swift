//
//  NoteEidtVC-Note.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/16/24.
//

import FirebaseFirestore

extension NoteEditVC{
    func createNote(){
        //Upload note to firebase
            StorageManager.shared.uploadNote(title: TitleTextField.exactText, text: textView.exactText, coverPhoto: photos[0], photos: photos, videoURL: videoURL) {
            result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.showTextHUD("Note successfully uploaded!", false)}
                print("Note successfully uploaded!")
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showTextHUD("Failed to upload note")}
                print("Failed to upload note: \(error.localizedDescription)")
            }
        }
        
        if draftNote != nil{
            navigationController?.popViewController(animated: true)
        }else{
            dismiss(animated: true)
        }
        
    }
    
    func updateNote(_ note: DocumentSnapshot){
        StorageManager.shared.updateNote(note, title: TitleTextField.exactText, text: textView.exactText, coverPhoto: photos[0], photos: photos, videoURL: videoURL) { result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self.showTextHUD("Note successfully update!", false)}
                self.updateNoteFinished?(note.getExactStringVal(kNoteID))
                print("Note successfully uploaded!")
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showTextHUD("Failed to update note")}
                print("Failed to upload note: \(error.localizedDescription)")
            }
        }

        dismiss(animated: true)
      
    }
    
    
    func postDraftNote(_ draftNote: DraftNote){
        createNote()
        //发布草稿笔记时需删掉这个草稿
        backgroundContext.perform {
            backgroundContext.delete(draftNote)
            appDelegate.saveBackgroundContext()
            
            //UI
            DispatchQueue.main.async {
                self.postDraftNoteFinished?()
            }
        }
        
    }
}
