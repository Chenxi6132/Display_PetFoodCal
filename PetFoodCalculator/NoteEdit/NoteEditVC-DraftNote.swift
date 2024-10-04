//
//  NoteEditVC-DraftNote.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/3/24.
//

import Foundation

extension NoteEditVC{
    // MARK: 创建草稿
    func createDraftNote(){
        backgroundContext.perform {
            let draftNote = DraftNote(context: backgroundContext)
            if self.isVideo{
                draftNote.video = try? Data(contentsOf: self.videoURL!)
            }
            self.handlePhotos(draftNote)
            
            draftNote.isVideo = self.isVideo
            self.handleOthers(draftNote)
            DispatchQueue.main.async {
                self.showTextHUD("Create Draft Successfully")
            }
        }
        dismiss(animated: true)
    }
    // MARK: 更新草稿
    func updateDraftNote(_ draftNote: DraftNote){
        backgroundContext.perform {
            if !self.isVideo{
                self.handlePhotos(draftNote)
            }
            
            self.handleOthers(draftNote)
            
            DispatchQueue.main.async {
                self.updateDraftNoteFinished?()
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
}

extension NoteEditVC{
    // MARK: handle photos
    private func handlePhotos(_ draftNote: DraftNote){
        draftNote.coverPhoto = photos[0].jpeg(.medium)
        
        var photos: [Data] = []
        
        for photo in self.photos{
            if let pngData = photo.pngData(){
                photos.append(pngData)
            }
        }
        
        draftNote.photos = try? JSONEncoder().encode(photos)
    }
    
    // MARK: handle other element In NoteEditVC
    private func handleOthers(_ draftNote: DraftNote){
        DispatchQueue.main.async {
            draftNote.title = self.TitleTextField.exactText
            draftNote.text = self.textView.exactText
        }
        draftNote.updateAt = Date()
        appDelegate.saveBackgroundContext()
    }
}
