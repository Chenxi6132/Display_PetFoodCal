//
//  WaterFallVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/17/24.
//

import UIKit
import XLPagerTabStrip
import FirebaseFirestore
import CHTCollectionViewWaterfallLayout
import FirebaseFirestoreInternal
import SegementSlide


class WaterFallVC: UICollectionViewController, SegementSlideContentScrollViewDelegate {
    
    @objc var scrollView: UIScrollView { collectionView }
    var channel = ""
    var draftNotes: [DraftNote] = []
    var isMyDraft: Bool = false
    
    var notes: [DocumentSnapshot] = []
    var lastDocument: DocumentSnapshot? // To keep track of the last document for pagination
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        getNotes()
        getDraftNote()
        
    }
    
    
    @IBAction func dismissDraftNote(_ sender: Any) {
        dismiss(animated: true)
    }
    
}


// MARK: - CHTCollectionViewDelegateWaterfallLayout  calculate cell size for the draft
extension WaterFallVC: CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellW = (screenRect.width - 3 * kWaterFallPadding)/2
        
        var cellH: CGFloat = 0
        if isMyDraft{
            let draftNote = draftNotes[indexPath.item]
            let imageSize = UIImage(draftNote.coverPhoto)?.size ?? imagePH.size
            let imageW = imageSize.width
            let imageH = imageSize.height
            let imageRatio = imageH/imageW
            cellH = imageRatio * cellW + kDraftNoteWaterfallCellBottomViewH
        }else{
            let note = notes[indexPath.item]
            let coverPhotoRatio = CGFloat(note.getExactDoubleVal(kCoverPhotoRatio))
            cellH = cellW * coverPhotoRatio + kDraftNoteWaterfallCellBottomViewH
        }
        return CGSize(width: cellW, height: cellH)
    }
}

extension WaterFallVC: IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        IndicatorInfo(title: channel)
    }
}

