//
//  isValidPassword.swift
//  KaapehApp
//
//  Created by Alumno on 21/11/25.
//

internal import Foundation
func isValidPassword(_ password: String) -> Bool {
    let minLength = password.count >= 8
    let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
    return minLength && hasNumber
}
