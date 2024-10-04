//
//  WaterFallVC-Delegate.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/4/24.
//

import Foundation

//if video/ photos load failed, do not pop to EditdraftView
extension WaterFallVC{
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isMyDraft{
            let draftNote = draftNotes[indexPath.item]
            
            if let photosData = draftNote.photos,
               let photosDataArray = try? JSONDecoder().decode([Data].self, from: photosData){
                let photos = photosDataArray.map { UIImage($0) ?? imagePH}
                let videoURL = FileManager.default.save(draftNote.video, to: "video", as: "\(UUID().uuidString).mp4")
                let vc = storyboard!.instantiateViewController(withIdentifier: kNoteEditVCID) as! NoteEditVC
                vc.draftNote = draftNote
                vc.photos = photos
                vc.videoURL = videoURL
                vc.updateDraftNoteFinished = {
                    self.getDraftNote()
                    self.deleteTempVideo(at: videoURL!)
                }
                
                //post note then delete draft
                vc.postDraftNoteFinished = {
                    self.getDraftNote()
                    self.deleteTempVideo(at: videoURL!)
                }
                navigationController?.pushViewController(vc, animated: true)
            }else{
                showTextHUD("Load Draft Failed")
                
            }
        }else{
            //go to note deails page independency injection
            let detailVC = storyboard!.instantiateViewController(identifier: kNoteDetailVCID) { coder in
                NoteDetailVC(coder: coder, note: self.notes[indexPath.item])
            }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? WaterFallCell{
                detailVC.isLikeFromWaterFallCell = cell.isLike
                detailVC.likeStatusChanged = { isLike in
                    cell.isLikeFromNoteDetailVC = detailVC.isLike
                    cell.likeBtn.isSelected = isLike
                }
            }
            
            detailVC.delNoteFinished = {
                self.notes.remove(at: indexPath.item)
                collectionView.performBatchUpdates { collectionView.deleteItems(at: [indexPath]) }
            }
            
            detailVC.modalPresentationStyle = .fullScreen
            present(detailVC, animated: true)
        }
    }
    
    func deleteTempVideo(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("Temporary video file deleted successfully.")
        } catch {
            print("Error deleting temporary video file: \(error)")
        }
    }
}
