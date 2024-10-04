//
//  NoteEditVC-setUI.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/5/24.
//

import Foundation
import PopupDialog

extension NoteEditVC{
    func setUI(){

        addPopup()
        setDraftNoteEditUI()
        setNoteEditVC()
    }
}



extension NoteEditVC{
    //editing Draft
    private func setDraftNoteEditUI(){
        if let draftNote = draftNote{
            TitleTextField.text = draftNote.title
            textView.text = draftNote.text
            //待做 话题 定位
        }
    }
    
    //editing Note
    private func setNoteEditVC(){
        if let note = note{
            TitleTextField.text = note.getExactStringVal(kTitle)
            textView.text = note.getExactStringVal(kText)
        }
    }
    

}


extension NoteEditVC{
////待做 话题 定位
}


//MARK: - add pop up dialog
extension NoteEditVC{
    private func addPopup(){
        let icon = largeIcon("info.circle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(showPopup))
        //content
        let pv = PopupDialogDefaultView.appearance()
        pv.titleColor = .label
        pv.messageFont = .systemFont(ofSize: 13)
        pv.messageColor = .label
        pv.messageTextAlignment = .left
        
        //cancel button
        let bv = CancelButton.appearance()
        bv.titleColor = .label
        bv.separatorColor = mainColor
        
        //popUpDialog container
        let pvc = PopupDialogContainerView.appearance()
        pvc.backgroundColor = .secondarySystemBackground
        pvc.cornerRadius = 10
    }

    
    
    @objc  private func showPopup(){
        let tile = "Community Guidelines"
        let message =
        """
        Please do not:
        1. Attack other commenters.
        2. Use profanity.
        3. Use language that is libelous, defamatory, obscene, threatening, offensive, demeaning, derogatory, disparaging, or abusive, or post links to content that contains any of this language.
        4. Degrade others on the basis of gender, race, class, ethnicity, national origin, religion, sexual preference, disability, or other classification.
        5. Make remarks that are off-topic.
        6. Write lengthy comments beyond the scope of the original post.
        7. Post spam.
        8. Post commercial messages.
        """
        let popUp = PopupDialog(title: tile, message: message, transitionStyle: .zoomIn)
        let btn = CancelButton(title: "Ok", action: nil)
        popUp.addButton(btn)
        present(popUp,animated: true)
    }
    
}

