//
//  TextViewIAView.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/26/24.
//

import UIKit

class TextViewIAView: UIView {

    @IBOutlet weak var textCountStackView: UIStackView!
    
    @IBOutlet weak var textCountLabel: UILabel!
    
    @IBOutlet weak var maxTextCountLabel: UILabel!
    
    @IBOutlet weak var doneBtn: UIButton!
    
    var currentTextCount = 0{
        didSet{
            if currentTextCount <= kMaxNoteTextCount{
                doneBtn.isHidden = false
                textCountStackView.isHidden = true
            }else{
                doneBtn.isHidden = true
                textCountStackView.isHidden = false
                textCountLabel.text = "\(currentTextCount)"
            }
        }
    }
}
