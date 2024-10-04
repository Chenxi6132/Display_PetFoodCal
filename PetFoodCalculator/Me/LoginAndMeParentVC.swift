//
//  LoginAndMeParentVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/10/24.
//
import UIKit

var loginAndMeParentVC = UIViewController()

class LoginAndMeParentVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSHomeDirectory())
        setupViewController()
        observeLoginStatus()

        //用一个强引用保存当前这个父vc,方便在登录和退出时找到正确的父vc
        loginAndMeParentVC = self
    }
        
    private func setupViewController() {
        if isUserLoggedIn() {
            let meVC = storyboard!.instantiateViewController(identifier: kMeVCID)
            add(child: meVC)
        } else {
            let loginVC = storyboard!.instantiateViewController(identifier: kLoginVCID)
            add(child: loginVC)
        }
    }
    
    private func observeLoginStatus() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc private func userDefaultsDidChange() {
        if isUserLoggedIn() {
            dismissAndShowMeVC()
        }
    }
    
}
    

extension LoginAndMeParentVC{
    
    func dismissAndShowMeVC(){
        hideLoadHUD()
        DispatchQueue.main.async {
            let mainSB = UIStoryboard(name: "Main", bundle: nil)
            let meVC = mainSB.instantiateViewController(identifier: kMeVCID)
            loginAndMeParentVC.removeChildren()
            loginAndMeParentVC.add(child: meVC)
            
            self.dismiss(animated: true)
        }
    }
}
