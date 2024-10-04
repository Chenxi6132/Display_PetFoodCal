//
//  SocialLogin.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/10/24.
//

import UIKit
import SwiftUI

class SocialLoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let loginView = Login() // Your SwiftUI login view
        let loginVC = UIHostingController(rootView: loginView)
        add(child: loginVC)
        print("not logged in")
        
        // Add Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    

}
