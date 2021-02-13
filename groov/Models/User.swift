//
//  User.swift
//  groov
//
//  Created by Alice Wu on 2/11/21.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {

    // MARK: - Properties
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    
    // MARK: - Init
    init(uid: String, firstName: String, lastName: String, email: String, password: String) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let firstName = dict["firstName"] as? String,
            let lastName = dict["lastName"] as? String,
            let email = dict["email"] as? String,
            let password = dict["password"] as? String
            else { return nil }

        self.uid = snapshot.key
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
    }
}
