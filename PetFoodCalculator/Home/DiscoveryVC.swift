//
//  DiscoveryVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 6/17/24.
//

import UIKit
import XLPagerTabStrip

class DiscoveryVC: ButtonBarPagerTabStripViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        //MARK: item setting such as discovery, catculator, dogculator
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15)
        
        //MARK: selected item under line setting
        settings.style.selectedBarHeight = 0
        
        super.viewDidLoad()
        
        containerView.bounces = false
        
        //MARK: high light  selected item
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = .secondaryLabel
            newCell?.label.textColor = .label
            
        }
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var vcs:[UIViewController] = []
        
        for channel in kChannels{
            let vc = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as! WaterFallVC
            vc.channel = channel
            vcs.append(vc)
        }
        
        return vcs
    }
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Discovery")
      }
    

}
