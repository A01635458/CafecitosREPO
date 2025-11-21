//
//  Models.swift
//  KaapehApp
//
//  Created by Alumnos on 20/11/25.
//
import Foundation

struct Profile: Decodable {
    let username: String?
    let email: String?
    let full_name: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case full_name
    }
}

struct UpdateProfileParams: Encodable {
    let username: String
    let full_name: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case full_name
    }
}

