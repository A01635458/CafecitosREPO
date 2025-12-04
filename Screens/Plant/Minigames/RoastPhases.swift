import SwiftUI

enum RoastPhase: String, CaseIterable, Identifiable {
    case drying
    case maillard
    case development
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .drying: return "Secado"
        case .maillard: return "Maillard"
        case .development: return "Desarrollo"
        }
    }
    
    var description: String {
        switch self {
        case .drying:
            return "Evapora la humedad del grano y prepara todo para las reacciones químicas."
        case .maillard:
            return "Se forman dulzor, cuerpo y notas tipo caramelo / pan tostado."
        case .development:
            return "Se define el nivel de tueste: acidez, dulzor y notas tostadas."
        }
    }
    
    /// Rango de temperatura “ideal” aproximado por fase (puedes tunearlo)
    var idealTempRange: ClosedRange<Double> {
        switch self {
        case .drying:
            return 140...160
        case .maillard:
            return 165...185
        case .development:
            return 190...205
        }
    }
    
    /// Duración ideal (en segundos) para hacer una evaluación básica
    var idealDuration: Double {
        switch self {
        case .drying: return 60
        case .maillard: return 75
        case .development: return 60
        }
    }
}

struct PhaseResult {
    let phase: RoastPhase
    let averageTemp: Double
    let duration: Double
}

struct RoastProfile {
    let name: String
    let summary: String
    let flavors: [String]
    let aromas: [String]
}
