//
//  CustomViews.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/24/24.
//

import Foundation

@IBDesignable
class bigButton: UIButton{
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shareInit()
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        shareInit()
    }
    
    private func shareInit(){
        backgroundColor = .secondarySystemBackground
        tintColor = .placeholderText
        setTitleColor(.placeholderText, for: .normal)
        
        contentHorizontalAlignment = .leading
        //contentInsets = UIEdgeInsets(top: <#T##CGFloat#>, left: <#T##CGFloat#>, bottom: <#T##CGFloat#>, right: <#T##CGFloat#>)
        
    }
    
}

