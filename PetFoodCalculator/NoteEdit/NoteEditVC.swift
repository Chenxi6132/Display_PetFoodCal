//
//  NoteEditVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/19/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class NoteEditVC: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var titleCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var draftNote: DraftNote?
    var note: DocumentSnapshot?
    var photos: [UIImage] = []
    var videoURL: URL?
    //var videoURL: URL = Bundle.main.url(forResource: "testVideo", withExtension: "mp4")!
    
    var photoCount : Int {photos.count}
    var isVideo : Bool {videoURL != nil}//if not nil, return true
    
    var updateDraftNoteFinished: (()->())?
    var postDraftNoteFinished: (()->())?
    var updateNoteFinished: ((String) -> ())?
    
    var textViewIAView: TextViewIAView { textView.inputAccessoryView as! TextViewIAView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        setUI()
    }
    
    @IBAction func TFEditBegin(_ sender: Any) {
        titleCountLabel.isHidden = false
    }
    
    @IBAction func TFEditEnd(_ sender: Any) {
        titleCountLabel.isHidden = true
    }
    
    @IBAction func TFEndOnExit(_ sender: Any) {}
    
    @IBAction func TFEditChanged(_ sender: Any) {handleTFEditChanged()}
    
    @IBAction func saveDraftNote(_ sender: Any) {
        guard isValidateNote() else {return}
        
        if let draftNote = draftNote{
            updateDraftNote(draftNote)
        }else{
            createDraftNote()
        }
    }
    
    
    @IBAction func postNote(_ sender: Any) {
        guard isValidateNote() else{return}
        
        if let draftNote = draftNote{ //post draftnote
            postDraftNote(draftNote)
            
        }else if let note = note{ //update postNote
            updateNote(note)
        }else{
            createNote() //postNote
            
        }
        
    }
}



extension NoteEditVC: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        guard textView.markedTextRange == nil else {return}
        textViewIAView.currentTextCount = textView.text.count
    }
}
