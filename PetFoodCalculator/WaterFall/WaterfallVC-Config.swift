//
//  WaterfallVC-Config.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/3/24.
//

import Foundation
import CHTCollectionViewWaterfallLayout

extension WaterFallVC{
    func config(){
        //let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        
        // 1: Explicitly Create and Set the CHTCollectionViewWaterfallLayout
        let layout = CHTCollectionViewWaterfallLayout()
        collectionView.collectionViewLayout = layout
        
        layout.columnCount = 2
        //MARK: setting the insect betweeen each cells
        layout.minimumColumnSpacing = kWaterFallPadding
        layout.minimumInteritemSpacing = kWaterFallPadding
        layout.sectionInset = UIEdgeInsets(top: kWaterFallPadding, left: kWaterFallPadding, bottom: kWaterFallPadding, right: kWaterFallPadding)
        
        if isMyDraft{
            navigationItem.title = "Draft"
        }
    }
}
