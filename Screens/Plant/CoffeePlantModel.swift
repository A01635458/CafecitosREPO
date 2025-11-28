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
    
    init(
        id: UUID = UUID(),
        name: String,
        varietal: String,
        createdAt: Date = .now,
        stage: CoffeeStage = .seed,
        stageStartedAt: Date = .now,
        water: Int = 50,
        light: Int = 30, // sombra
        lastWaterUpdate: Date? = nil,
        lastLightUpdate: Date? = nil,
        qualityAccumulated: Double = 0,
        qualitySamples: Int = 0
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
    }
}

// MARK: - Reglas de ambiente por etapa

/// Rango ideal de agua y luz para una etapa
struct EnvironmentRequirement {
    let waterRange: ClosedRange<Int>?  // 0–100
    let lightRange: ClosedRange<Int>?  // 0–100
}

struct EnvironmentRules {
    // Ajusta los rangos según cómo quieras que se comporte tu "tamagotchi"
    static let requirements: [CoffeeStage: EnvironmentRequirement] = [
        .seed: EnvironmentRequirement(
            waterRange: 60...80,   // húmedo constante
            lightRange: 10...30    // sombra
        ),
        .germination: EnvironmentRequirement(
            waterRange: 60...80,
            lightRange: 10...30
        ),
        .seedling: EnvironmentRequirement(
            waterRange: 50...70,
            lightRange: 30...50    // sombra parcial
        ),
        .juvenile: EnvironmentRequirement(
            waterRange: 50...70,
            lightRange: 30...50
        ),
        .transplanted: EnvironmentRequirement(
            waterRange: 50...70,
            lightRange: 20...40    // un poco más de sombra tras el estrés
        ),
        .vegetative: EnvironmentRequirement(
            waterRange: 40...60,
            lightRange: 40...70
        ),
        .flowering: EnvironmentRequirement(
            waterRange: 40...60,
            lightRange: 40...70
        ),
        .greenCherry: EnvironmentRequirement(
            waterRange: 40...60,
            lightRange: 60...100   // más sol
        ),
        .ripeCherry: EnvironmentRequirement(
            waterRange: 40...60,
            lightRange: 60...100
        ),
        // A partir de aquí el cafeto como planta ya no importa tanto,
        // son procesos post-cosecha:
        .harvest: EnvironmentRequirement(
            waterRange: nil,
            lightRange: nil
        ),
        .processing: EnvironmentRequirement(
            waterRange: nil,
            lightRange: nil
        ),
        .drying: EnvironmentRequirement(
            waterRange: nil,
            lightRange: 60...100   // sol para secado
        ),
        .roasting: EnvironmentRequirement(
            waterRange: nil,
            lightRange: nil
        ),
        .cup: EnvironmentRequirement(
            waterRange: nil,
            lightRange: nil
        )
    ]
    
    static func requirement(for stage: CoffeeStage) -> EnvironmentRequirement? {
        requirements[stage]
    }
}

// MARK: - Lógica de juego (riego, luz, progreso, avances)

extension CoffeePlant {
    //  La lógica de "qué tan cerca" está de los rangos (0–1)
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
        guard let req = EnvironmentRules.requirement(for: stage) else {
            return 1.0 // si no hay requisitos para esta etapa, cuenta como perfecto
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
        guard let req = EnvironmentRules.requirement(for: stage) else {
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
    
    // Score final de taza (0–100)
    var finalCupScore: Int {
        guard qualitySamples > 0 else { return 0 }
        let normalized = qualityAccumulated / Double(qualitySamples) // 0–1
        return Int((normalized * 100).rounded())
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
