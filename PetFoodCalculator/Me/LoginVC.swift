//
//  LoginVC.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/10/24.
//
import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(identifier: kSocialLoginVCID) as! SocialLoginVC
        present(vc, animated: true)
    }
}

