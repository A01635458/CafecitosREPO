import Foundation

enum CoffeeVarietal: String, CaseIterable, Identifiable {
    case bourbon = "Bourbon"
    case typica = "Typica"
    case hidalgo = "Pluma Hidalgo"
    case geisha = "Geisha"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bourbon:    return "Bourbon"
        case .typica:     return "Typica"
        case .hidalgo: return "Pluma Hidalgo"
        case .geisha:     return "Geisha"
        }
    }
}

