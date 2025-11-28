import Foundation

enum CoffeeVarietal: String, CaseIterable, Identifiable {
    case bourbon = "Bourbon"
    case typica = "Typica"
    case maragogipe = "Maragogipe"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bourbon:    return "Bourbon"
        case .typica:     return "Typica"
        case .maragogipe: return "Maragogipe"
        }
    }
}

