//
//  WaterFallVC-DataSource.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/5/24.
//

import Foundation

extension WaterFallVC{
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if isMyDraft{
            return draftNotes.count
        }else{
            return notes.count
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isMyDraft{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kDraftNoteWaterFallCellID, for: indexPath) as! DraftNoteWaterFallCell
            cell.draftNote = draftNotes[indexPath.item]
            cell.deleteBtn.tag = indexPath.item
            cell.deleteBtn.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWaterFallCellID, for: indexPath) as! WaterFallCell
            
            cell.note = notes[indexPath.item]
        
            return cell
        }
        
    }


}


extension WaterFallVC{
    @objc private func showAlert(_ sender: UIButton){
        let index = sender.tag
        let alert = UIAlertController(title: "Prompt", message: "Delete The Draft?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Cancel", style: .cancel)
        let action2 = UIAlertAction(title: "Confirm", style: .destructive){
            _ in self.deleteDraftNote(index)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert,animated: true)
    }
}

extension WaterFallVC{
    private func deleteDraftNote(_ index: Int){
        backgroundContext.perform {
            let draftNote = self.draftNotes[index]
            backgroundContext.delete(draftNote)
            appDelegate.saveBackgroundContext()
            
            self.draftNotes.remove(at: index)
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.showTextHUD("delete draft successful")
            }
        }
    }
}
