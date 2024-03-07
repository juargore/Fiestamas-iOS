//
//  ValidateEmailFormat.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 23/05/23.
//

import Foundation

func validateEmailFormat(_ email: String) -> Bool {
    let emailFormat = "[A-Z0-9a-z_.%+-]+@[A-Za-z0-9..-]+.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: email)
}

func validatePasswordFormat(_ password: String) -> Bool {
//    Minimum eight characters, at least one uppercase letter, one lowercase letter, one number and one special character
    let passwordFormat = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8}$"
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
    return passwordPredicate.evaluate(with: password)
}
