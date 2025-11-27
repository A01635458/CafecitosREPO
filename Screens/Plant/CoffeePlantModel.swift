import SwiftData
import Foundation

// MARK: - Modelo principal

@Model
class CoffeePlant {
    @Attribute(.unique) var id: UUID
    var name: String
    var varietal: String
    var createdAt: Date
    var stage: CoffeeStage
    var stageStartedAt: Date   // ⬅️ para calcular el progreso de la etapa

    /// Nivel de agua de la planta (0–100)
    var water: Int             // 0–100
    /// Nivel de luz que recibe la planta (0–100)
    var light: Int             // 0–100
    
    var lastWaterUpdate: Date?
    var lastLightUpdate: Date?
    
    init(
        id: UUID = UUID(),
        name: String,
        varietal: String = "Bourbon",
        createdAt: Date = .now,
        stage: CoffeeStage = .seed,
        stageStartedAt: Date = .now,
        water: Int = 50,
        light: Int = 30, // sombra
        lastWaterUpdate: Date? = nil,
        lastLightUpdate: Date? = nil
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
    
    /// ¿La planta cumple los requisitos de agua y luz para su etapa actual?
    var environmentRequirementsMet: Bool {
        guard let req = EnvironmentRules.requirement(for: stage) else {
            return true // si no hay requisitos, lo consideramos cumplido
        }
        
        if let waterRange = req.waterRange, !waterRange.contains(water) {
            return false
        }
        if let lightRange = req.lightRange, !lightRange.contains(light) {
            return false
        }
        return true
    }
    
    /// Acción de riego (sube el nivel de agua)
    func waterPlant(amount: Int = 10) {
        water = min(100, water + amount)
        lastWaterUpdate = .now
    }
    
    
    
    /// Cambiar luz a un valor específico (slider, pasos, etc.)
    func changeLight(to newValue: Int) {
        light = max(0, min(100, newValue))
        lastLightUpdate = .now
    }
    
    /// Progreso de la etapa actual (0–1) según el tiempo
    var stageProgress: Double {
        let now = Date()
        let elapsed = now.timeIntervalSince(stageStartedAt)
        let duration = CoffeeStageTimeline.duration[stage] ?? 0
        
        guard duration > 0 else { return 1.0 }
        return min(max(elapsed / duration, 0), 1)
    }
    
    /// Intenta avanzar de etapa si ya pasó el tiempo y el ambiente es el correcto
    func updateStageIfNeeded() {
        // Si ya está en la última etapa, no hacemos nada
        guard let duration = CoffeeStageTimeline.duration[stage],
              duration > 0
        else { return }
        
        let now = Date()
        let elapsed = now.timeIntervalSince(stageStartedAt)
                
        // 2) Revisar si riego + luz están correctos
        guard environmentRequirementsMet else {
            // Aquí podrías penalizar calidad final, mostrar mensaje, etc.
            return
        }
        
        // 3) Avanzar de etapa
        if let next = CoffeeStageTimeline.nextStage(after: stage) {
            self.stage = next
            self.stageStartedAt = now
        }
    }
}

