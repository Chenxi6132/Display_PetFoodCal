//
//  PhotoFooter.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/20/24.
//

import UIKit

class PhotoFooter: UICollectionReusableView {
    @IBOutlet weak var addPhotoBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        addPhotoBtn.layer.borderColor = UIColor.quaternaryLabel.cgColor
        addPhotoBtn.layer.borderWidth = 1
    }
            
}
