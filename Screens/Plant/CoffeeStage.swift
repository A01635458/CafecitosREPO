import Foundation

enum CoffeeStage: String, Codable, CaseIterable {
    case seed
    case germination
    case seedling
    case juvenile
    case transplanted
    case vegetative
    case flowering
    case greenCherry
    case ripeCherry
    case harvest
    case processing
    case roasting
    case cup
    
    var displayName: String {
        switch self {
        case .seed:          return "Semilla"
        case .germination:   return "Germinación"
        case .seedling:      return "Plántula"
        case .juvenile:      return "Juvenil"
        case .transplanted:  return "Trasplante"
        case .vegetative:    return "Desarrollo vegetativo"
        case .flowering:     return "Floración"
        case .greenCherry:   return "Fruto verde"
        case .ripeCherry:    return "Maduración"
        case .harvest:       return "Cosecha"
        case .processing:    return "Beneficio"
        case .roasting:      return "Tostado"
        case .cup:           return "Taza final"
        }
    }
}

struct CoffeeStageTimeline {
    // Duración recomendada de cada etapa (en segundos)
    static let duration: [CoffeeStage: TimeInterval] = [
        .seed:         2 * 60 * 60,  // 2 h
        .germination:  4 * 60 * 60,
        .seedling:     6 * 60 * 60,
        .juvenile:     8 * 60 * 60,
        .transplanted: 8 * 60 * 60,
        .vegetative:   10 * 60 * 60,
        .flowering:    6 * 60 * 60,
        .greenCherry:  8 * 60 * 60,
        .ripeCherry:   8 * 60 * 60,
        .harvest:      2 * 60 * 60,
        .processing:   2 * 60 * 60,
        .roasting:     1 * 60 * 60,
        .cup:          0 // Etapa final
    ]
    
    static func nextStage(after stage: CoffeeStage) -> CoffeeStage? {
        let all = CoffeeStage.allCases
        guard let idx = all.firstIndex(of: stage),
              idx + 1 < all.count
        else { return nil }
        return all[idx + 1]
    }
}

extension CoffeeStage {
    /// Etapas donde el ambiente (agua/luz) del cafeto todavía importa
    var preharvest: Bool {
        switch self {
        case .seed,
             .germination,
             .seedling,
             .juvenile,
             .transplanted,
             .vegetative,
             .flowering,
             .greenCherry,
             .ripeCherry:
            return true
        case .harvest,
             .processing,
             .roasting,
             .cup:
            return false
        }
    }
}
