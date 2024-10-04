//
//  NoteEditVC-Helper.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/3/24.
//

import Foundation

extension NoteEditVC{
    func isValidateNote() -> Bool{
        guard !photos.isEmpty else{
            showTextHUD("Please Select at Least One Picutre")
            return false}
        
        guard textViewIAView.currentTextCount <= kMaxNoteTextCount else{
            showTextHUD("The text supports up to \(kMaxNoteTextCount) characters.")
            return false
        }
        return true
    }
    
    
    func handleTFEditChanged(){
        guard TitleTextField.markedTextRange == nil else {return}
        
        if TitleTextField.unwrappedText.count > kMaxNoteTitleCount{
            TitleTextField.text = String(TitleTextField.unwrappedText.prefix(kMaxNoteTitleCount))
            
            showTextHUD("Max length of title is \(kMaxNoteTitleCount)")
            
            DispatchQueue.main.async {
                let end = self.TitleTextField.endOfDocument
                self.TitleTextField.selectedTextRange = self.TitleTextField.textRange(from: end, to: end)
            }
        }
        titleCountLabel.text = "\(kMaxNoteTitleCount - TitleTextField.unwrappedText.count)"
    }
}
