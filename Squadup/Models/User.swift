//
//  User.swift
//  Squadup
//
//  Created by Jack Liu on 7/18/18.
//  Copyright © 2018 Jack Liu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase.FIRDataSnapshot

//import FirebaseDatabase.FIRDataSnapshot

class User: Codable {
    
    // MARK: - Properties
    
    let uid: String
    let username: String
    let latitude: Double
    let longitude: Double
    private static var _current: User?
    // MARK: - Init
    
    init(uid: String, username: String, latitude: Double, longitude: Double) {
        self.uid = uid
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String,
        let latitude = dict["latitude"] as? Double,
        let longitude = dict["longitude"] as? Double
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static var current: User {
        // 3
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        // 4
        return currentUser
    }
    
    // MARK: - Class Methods
    
    // 5
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        // 2
        if writeToUserDefaults {
            // 3
            if let data = try? JSONEncoder().encode(user) {
                // 4
                UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
            }
        }
        
        _current = user
    }
    
    
    
    
    
}
