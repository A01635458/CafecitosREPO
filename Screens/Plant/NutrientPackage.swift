import Foundation

enum NutrientPackage: String, CaseIterable, Identifiable {
    case small
    case medium
    case large
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .small:  return "Paquete chico"
        case .medium: return "Paquete mediano"
        case .large:  return "Paquete grande"
        }
    }
}

struct NutrientRules {
    static func recommendedPackage(for stage: CoffeeStage) -> NutrientPackage {
        switch stage {
        case .seed, .germination:
            return .small
        case .seedling, .juvenile, .vegetative:
            return .large
        case .flowering:
            return .medium
        case .greenCherry:
            return .small
        case .ripeCherry, .harvest, .processing, .roasting, .cup:
            return .small
        case .transplanted:
            return .small
        }
    }
}

