//
//  CreateUsernameViewController.swift
//  Squadup
//
//  Created by Jack Liu on 7/18/18.
//  Copyright © 2018 Jack Liu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase


class CreateUsernameViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // 1
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else { return }
            
            User.setCurrent(user, writeToUserDefaults: true)
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController")
            self.view.window?.rootViewController = initialViewController
            self.view.window?.makeKeyAndVisible()
            
        }
        
        
//        // 2
//        let userAttrs = ["username": username]
//
//        // 3
//        let ref = Database.database().reference().child("users").child(firUser.uid)
//
//        // 4
//        ref.setValue(userAttrs) { (error, ref) in
//            if let error = error {
//                assertionFailure(error.localizedDescription)
//                return
//            }
//
//            // 5
//            ref.observeSingleEvent(of: .value, with: { (snapshot) in
//                let user = User(snapshot: snapshot)
//
//            })
//        }
    }
    
    
    
    
}
