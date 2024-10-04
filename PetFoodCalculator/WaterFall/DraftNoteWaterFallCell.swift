//
//  DraftNoteWaterFallCell.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/5/24.
//

import UIKit

class DraftNoteWaterFallCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var isVideoImageView: UIImageView!
    
    var draftNote: DraftNote?{
        didSet{
            guard let draftNote = draftNote else{ return }
            
            imageView.image = UIImage(draftNote.coverPhoto) ?? imagePH
            let title = draftNote.title!
            titleLabel.text = title.isEmpty ? "None title" : title
            dateLabel.text = draftNote.updateAt?.formattedDate
            isVideoImageView.isHidden = !draftNote.isVideo
            
            
        }
    }
    
}
