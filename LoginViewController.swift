//
//  ViewController.swift
//  Squadup
//
//  Created by Jack Liu on 7/16/18.
//  Copyright © 2018 Jack Liu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var directMapButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionViewMap(_ sender: UIButton) {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    

}

