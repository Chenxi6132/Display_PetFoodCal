//
//  CatCulatorVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/17/24.
//

import UIKit
import XLPagerTabStrip

class CatCulatorVC: UIViewController,IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "CatCulator")
    }
    
}
