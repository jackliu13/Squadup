//
//  ViewController.swift
//  Squadup
//
//  Created by Jack Liu on 7/16/18.
//  Copyright © 2018 Jack Liu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {

    @IBOutlet weak var directMapButton: UIButton!
    
    @IBOutlet weak var directUsernameButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        authUI.delegate = self
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)

    }
    
    @IBAction func actionGoToMap(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMap", sender: self)
    }
    
    
    @IBAction func actionGoToUsername(_ sender: Any) {
        self.performSegue(withIdentifier: "toUsername", sender: self)
    }
    
    

    
}

extension LoginViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            assertionFailure("Error signing in: \(error.localizedDescription)")
            return
        }
        
        guard let user = authDataResult?.user
            else { return }
        
        let userRef = Database.database().reference().child("users").child(user.uid)
        userRef.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            if let user = User(snapshot: snapshot) {
                print("Welcome back, \(user.username).")
            } else {
                self.performSegue(withIdentifier: "toCreateUsername", sender: self)
            }
        })
    }
}

