//
//  CameraGameModel.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import Foundation


struct CoffeeMission: Identifiable, Codable {
    let id = UUID()
    let label: String
    let trait: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case trait
    }
}


struct ScanResult: Equatable {
    let id = UUID()
    let success: Bool
    let message: String
}


