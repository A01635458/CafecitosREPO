import SwiftData
import Foundation

// MARK: - Modelo principal

@Model
class CoffeePlant {
    // Detalles de la planta
    @Attribute(.unique) var id: UUID
    var name: String
    var varietal: String
    var createdAt: Date
    var stage: CoffeeStage // Etapa de crecimiento
    var stageStartedAt: Date

    // Variables para jugabilidad
    var water: Int             // Nivel de agua de la planta (0–100)
    var light: Int             // Nivel de luz
    var lastWaterUpdate: Date?
    var lastLightUpdate: Date?
    var qualityAccumulated: Double // calidad de la planta acumulada
    var qualitySamples: Int // cuantas etapas han aportado
    var nutrientBonus: Double // nutrientes
    var benefitProcessRaw: String?
    
    // Tueste
    var roastLevel: String?
    var roastSummary: String?
    var roastFlavors: String?
    var roastAromas: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        varietal: String,
        createdAt: Date = .now,
        stage: CoffeeStage = .seed,
        stageStartedAt: Date = .now,
        water: Int = 0,
        light: Int = 0, // sombra
        lastWaterUpdate: Date? = nil,
        lastLightUpdate: Date? = nil,
        qualityAccumulated: Double = 0,
        qualitySamples: Int = 0,
        nutrientBonus: Double = 0
    ) {
        self.id = id
        self.name = name
        self.varietal = varietal
        self.createdAt = createdAt
        self.stage = stage
        self.stageStartedAt = stageStartedAt
        self.water = water
        self.light = light
        self.lastWaterUpdate = lastWaterUpdate
        self.lastLightUpdate = lastLightUpdate
        self.qualityAccumulated = qualityAccumulated
        self.qualitySamples = qualitySamples
        self.nutrientBonus = nutrientBonus
    }
}

// MARK: - Reglas de ambiente por etapa

/// Rango ideal de agua y luz para una etapa
struct EnvironmentRequirement {
    let waterRange: ClosedRange<Int>?  // 0–100
    let lightRange: ClosedRange<Int>?  // 0–100
}

struct EnvironmentRules {
    
    static let baseRequirements: [CoffeeStage: EnvironmentRequirement] = [
        .seed: EnvironmentRequirement( // 1
            waterRange: 60...80,   // húmedo constante
            lightRange: 32...35   // sombra
                                     ),
        .germination: EnvironmentRequirement( // 2
            waterRange: 60...80,
            lightRange: 32...35
                                            ),
        .seedling: EnvironmentRequirement( // 3
            waterRange: 50...70,
            lightRange: 65...67    // sombra parcial
                                         ),
        .juvenile: EnvironmentRequirement( // 4
            waterRange: 50...70,
            lightRange: 65...67
                                         ),
        .transplanted: EnvironmentRequirement( // 5
            waterRange: 50...70,
            lightRange: 32...35   // un poco más de sombra tras el estrés
                                             ),
        .vegetative: EnvironmentRequirement( // 6
            waterRange: 40...60,
            lightRange: 65...67
                                           ),
        .flowering: EnvironmentRequirement( // 7
            waterRange: 40...60,
            lightRange: 65...67
                                          ),
        .greenCherry: EnvironmentRequirement( // 8
            waterRange: 40...60,
            lightRange: 98...100   // más sol
                                            ),
        .ripeCherry: EnvironmentRequirement( // 9
            waterRange: 40...60,
            lightRange: 98...100 
                                           ),
        // A partir de aquí el cafeto como planta ya no importa tanto,
        // son procesos post-cosecha:
            .harvest: EnvironmentRequirement( // 10
                waterRange: nil,
                lightRange: nil
                                            ),
        .processing: EnvironmentRequirement( // 11
            waterRange: nil,
            lightRange: nil
                                           ),
        .roasting: EnvironmentRequirement( // 13
            waterRange: nil,
            lightRange: nil
                                         ),
        .cup: EnvironmentRequirement( // 14
            waterRange: nil,
            lightRange: nil
                                    )
    ]
    
    static let varietalOverrides: [CoffeeVarietal: [CoffeeStage: EnvironmentRequirement]] = [
        .typica: typicaOverrides,
        .geisha: geishaOverrides,
        .hidalgo: plumaHidalgoOverrides
    ]
    
    static func requirement(for stage: CoffeeStage,
                               varietal: CoffeeVarietal) -> EnvironmentRequirement? {

           if let override = varietalOverrides[varietal]?[stage] {
               return override
           }

           return baseRequirements[stage]
       }
    
}

// MARK: - Lógica de juego (riego, luz, progreso, avances)

extension CoffeePlant {
    
    var isPostHarvestStage: Bool {
        switch stage {
        case .harvest, .processing, .roasting, .cup:
            return true
        default:
            return false
        }
    }
    
    var stageTime: String {
        let seconds = Date().timeIntervalSince(stageStartedAt)
        
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = hours / 24
        
        if days > 0 {
            return "\(days) día\(days == 1 ? "" : "s") \(hours % 24) h"
        } else if hours > 0 {
            return "\(hours) h \(minutes % 60) min"
        } else {
            return "\(minutes) min"
        }
    }
    
    var varietalType: CoffeeVarietal {
            CoffeeVarietal(rawValue: varietal) ?? .bourbon
        }
    //  "qué tan cerca" está de los rangos (0–1)
    private func score(value: Int, in range: ClosedRange<Int>) -> Double {
        if range.contains(value) {
            return 1.0
        }
        let dist: Double
        if value < range.lowerBound {
            dist = Double(range.lowerBound - value)
        } else {
            dist = Double(value - range.upperBound)
        }
        // mientras más lejos del rango, peor score; a partir de ~50 puntos de diferencia es 0
        let maxDist: Double = 50.0
        return max(0.0, 1.0 - dist / maxDist)
    }
    
    // Score de calidad por etapa según agua + luz (0–1)
    func stageQualityScore() -> Double {
        // 👉 Para etapas post-cosecha ya no medimos agua/luz
        if isPostHarvestStage {
            return 1.0
        }
        
        guard let req = EnvironmentRules.requirement(for: stage, varietal: varietalType) else {
            // si no hay requisitos configurados, cuenta como perfecto
            return 1.0
        }
        
        var total = 0.0
        var factors = 0.0
        
        if let waterRange = req.waterRange {
            total += score(value: water, in: waterRange)
            factors += 1
        }
        if let lightRange = req.lightRange {
            total += score(value: light, in: lightRange)
            factors += 1
        }
        
        guard factors > 0 else { return 1.0 }
        return total / factors
    }
    
    // Registrar la calidad de la etapa actual en los acumuladores globales
    func registerStageQuality() {
        let s = stageQualityScore()
        qualityAccumulated += s
        qualitySamples += 1
    }
    
    var environmentRequirementsMet: Bool {
        guard let req = EnvironmentRules.requirement(for: stage, varietal: varietalType) else {
            return true
        }
        if let waterRange = req.waterRange, !waterRange.contains(water) {
            return false
        }
        if let lightRange = req.lightRange, !lightRange.contains(light) {
            return false
        }
        return true
    }
    
    // Acciones de agua/luz
    func waterPlant(amount: Int = 20) {
        water = min(100, water + amount)
        lastWaterUpdate = .now
    }
    
    func changeLight(to newValue: Int) {
        light = max(0, min(100, newValue))
        lastLightUpdate = .now
    }
    
    @discardableResult
    func applyNutrients(_ package: NutrientPackage) -> Bool {
        let recommended = NutrientRules.recommendedPackage(for: stage)
        
        if package == recommended {
            // Elección correcta → sumamos bonus
            nutrientBonus += 0.5     // puedes ajustar magnitud
            return true
        } else {
            // Elección incorrecta → penalizamos un poco
            nutrientBonus -= 0.25
            return false
        }
    }
    
    var benefitProcess: BenefitProcess? {
        get {
            guard let raw = benefitProcessRaw else { return nil }
            return BenefitProcess(rawValue: raw)
        }
        set {
            benefitProcessRaw = newValue?.rawValue
        }
    }
    
    var benefitBonus: Double {
        switch benefitProcess {
        case .washed:
            // taza muy limpia
            return 0.03
        case .honey:
            // mucho dulzor
            return 0.05
        case .natural:
            // frutal intenso
            return 0.04
        case nil:
            return 0.0
        }
    }
    
    var stageProgress: Double {
        let now = Date()
        let elapsed = now.timeIntervalSince(stageStartedAt)
        let duration = CoffeeStageTimeline.duration[stage] ?? 0
        guard duration > 0 else { return 1.0 }
        return min(max(elapsed / duration, 0), 1)
    }
    
    // Avanzar etapa
    func updateStageIfNeeded() {
        // Si ya está en la última etapa, no hacemos nada
        guard let duration = CoffeeStageTimeline.duration[stage],
              duration > 0
        else { return }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(stageStartedAt)
        
        
        registerStageQuality()
        
        if let next = CoffeeStageTimeline.nextStage(after: stage) {
            self.stage = next
            self.stageStartedAt = now
        }
    }
    
    var timeInStageDescription: String {
        let seconds = Date().timeIntervalSince(stageStartedAt)
        
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = hours / 24
        
        if days > 0 {
            return "\(days) día\(days == 1 ? "" : "s") \(hours % 24) h"
        } else if hours > 0 {
            return "\(hours) h \(minutes % 60) min"
        } else {
            return "\(minutes) min"
        }
    }

    
    // Score final de taza (0–100)
    var finalCupScore: Int {
        // Si nunca registraste etapas, usa solo nutrientes + beneficio
        guard qualitySamples > 0 else {
            let base = (nutrientBonus / 5.0) + benefitBonus
            let clamped = max(0.0, min(1.0, base))
            return Int((clamped * 100).rounded())
        }
        
        let baseQuality = qualityAccumulated / Double(qualitySamples) // 0–1
        let combined = baseQuality
                     + (nutrientBonus / 10.0)
                     + benefitBonus
        let clamped = max(0.0, min(1.0, combined))
        return Int((clamped * 100).rounded())
    }
    
    // Texto de calificación (opcional)
    var finalCupGrade: String {
        let score = finalCupScore
        switch score {
        case 90...100: return "Excelente"
        case 80..<90:  return "Muy buena"
        case 70..<80:  return "Buena"
        case 60..<70:  return "Aceptable"
        default:       return "Baja calidad"
        }
    }
}

enum BenefitProcess: String, Codable, CaseIterable {
    case washed    // lavado
    case honey     // honey / miel
    case natural   // natural
}
