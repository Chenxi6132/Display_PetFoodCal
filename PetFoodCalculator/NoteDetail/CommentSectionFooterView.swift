//
//  CommentSectionFooterView.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 9/6/24.
//

import UIKit

class CommentSectionFooterView: UITableViewHeaderFooterView {

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        tintColor = .systemBackground
        let separatorLine = UIView(frame: CGRect(x: 62, y: 0, width: screenRect.width - 62, height: 1))
        separatorLine.backgroundColor = .quaternaryLabel
        
        addSubview(separatorLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
