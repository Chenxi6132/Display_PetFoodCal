//
//  MeVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/5/24.
//

import UIKit
import SwiftUI
import Firebase
import GoogleSignIn
import SegementSlide

class MeVC: SegementSlideDefaultViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.backButtonDisplayMode = .minimal
        setUI()
        defaultSelectedIndex = 0
        reloadData()
        
    }
    
    override func segementSlideHeaderView() -> UIView? {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = mainColor
        headerView.heightAnchor.constraint(equalToConstant: view.bounds.height/4).isActive = true
        return headerView
    }

    override var titlesInSwitcher: [String] {
        return ["Note", "Like", "Fav"]
    }
    
    override var switcherConfig: SegementSlideDefaultSwitcherConfig{
        var config = super.switcherConfig
        config.type = .tab
        config.selectedTitleColor = .label
        config.indicatorColor = mainColor
        
        return config
    }

    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        let vc = storyboard!.instantiateViewController(identifier: kWaterFallVCID) as! WaterFallVC
        return vc
    }

    

//    @IBAction func showDraftNotes(_ sender: Any) {
//        let navi = storyboard!.instantiateViewController(withIdentifier: kDraftNotesNaviID)
//        navi.modalPresentationStyle = .fullScreen
//        present(navi, animated: true)
//    }
//    
//    @IBAction func logoutBtn(_ sender: Any) {
//        do {
//            try Auth.auth().signOut()
//            GIDSignIn.sharedInstance.signOut()
//            
//            // Update logStatus in UserDefaults
//            UserDefaults.standard.set(false, forKey: "log_status")
//            
//            let loginVC = storyboard!.instantiateViewController(identifier: kLoginVCID)
//            
//            loginAndMeParentVC.removeChildren()
//            loginAndMeParentVC.add(child: loginVC)
//            
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//    }
    
}
