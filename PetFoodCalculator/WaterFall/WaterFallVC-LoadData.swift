//
//  WaterFallVC-LoadData.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/5/24.
//
import CoreData
import UIKit
import FirebaseFirestore

extension WaterFallVC{
    
    func getDraftNote(){
        let request = DraftNote.fetchRequest()
        
        let sortRule1 = NSSortDescriptor(key: "updateAt", ascending: false)
        request.sortDescriptors = [sortRule1]
        
        request.propertiesToFetch = ["coverPhoto", "title", "updateAt", "isVideo"]
        
        showLoadHUD()
        backgroundContext.perform {
            if let draftNotes = try? backgroundContext.fetch(request){
                self.draftNotes = draftNotes
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            self.hideLoadHUD()
        }
    }
    
    func getNotes() {
        let db = Firestore.firestore()
        //待做channel
        var query: Query = db.collection("Notes")
            .order(by: kDate, descending: true)
            .limit(to: 20)
        
        // If there's a last document, start the query after it
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Update the last document
            self.lastDocument = documents.last
            
            // Append new documents to the notes array
            self.notes.append(contentsOf: documents)
            self.collectionView.reloadData()
        }
    }
}
