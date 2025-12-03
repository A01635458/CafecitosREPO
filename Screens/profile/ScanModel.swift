//
//  ScanModel.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import Foundation

struct ScanModel: Identifiable, Decodable {
    let id: UUID
    let user_id: UUID
    let label: String
    let info: String
    let specialtyimpact: String
    let preventiontips: String
    let captured_at: String

    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case label
        case info
        case specialtyimpact
        case preventiontips
        case captured_at
    }
    
    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: captured_at) else {
            return captured_at 
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "es_MX")
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short

        return displayFormatter.string(from: date)
    }
}
