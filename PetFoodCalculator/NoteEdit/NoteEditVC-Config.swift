//
//  NoteEditVC-Config.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/26/24.
//

import Foundation

extension NoteEditVC{
    func config(){
        hideKeyboardWhenTappedAround()
        
        //enable drag interaction
        photoCollectionView.dragInteractionEnabled = true
        
        //titleContLabel
        titleCountLabel.text = "\(kMaxNoteTitleCount)"
        
        //textView insect
        let linePadding = textView.textContainer.lineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(top: 0, left: -linePadding , bottom: 0, right: -linePadding)
        textView.textContainer.lineFragmentPadding = 0
        
        //textview lineSpace, Font, and Color
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let typeAttrubutes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.secondaryLabel
        ]
        textView.typingAttributes = typeAttrubutes
        
        //xib load view
        textView.inputAccessoryView = Bundle.loadView(fromNib: "TextViewIAView", with: TextViewIAView.self)
        
        //inputAccessaryView
        textViewIAView.doneBtn.addTarget(self, action: #selector(resignTextView), for: .touchUpInside)
        textViewIAView.maxTextCountLabel.text = "/\(kMaxNoteTextCount)"
        
        print(NSHomeDirectory())
    }
}

extension NoteEditVC{
    @objc private func resignTextView(){
        textView.resignFirstResponder()
    }
}
