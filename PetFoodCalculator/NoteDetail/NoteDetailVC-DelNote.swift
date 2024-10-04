//
//  NoteDetailVC-DelNote.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 8/18/24.
//

import FirebaseFirestore

extension NoteDetailVC{
    func delNote(){
       showDelAlert(for: "Note") { _ in
            //Database in firebase
            self.delFBNote()
            
            //UI
            self.dismiss(animated: true){
                self.delNoteFinished?()
            }
        }
    }
    private func delFBNote() {
        let noteID = note.getExactStringVal(kNoteID)
        let userID = note.getExactStringVal(kUID)
        db.collection("Notes").document(noteID).delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.showTextHUD("Successfully Delete The Note")}
            }
        }
        StorageManager.shared.deleteStorageFolder(noteID, userID)
        
                                                  
    }
}
