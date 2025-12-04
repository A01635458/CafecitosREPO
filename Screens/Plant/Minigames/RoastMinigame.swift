import SwiftUI
import Foundation
import Combine

struct RoastMinigameView: View {
    var onFinish: ((RoastProfile) -> Void)?
    
    // Fases
    private let phases = RoastPhase.allCases
    
    // Estado del juego
    @State private var currentPhaseIndex: Int = 0
    @State private var currentTemp: Double = 150
    @State private var isRunning: Bool = false
    @State private var elapsedInPhase: Double = 0
    
    // Para calcular promedio de temperatura en cada fase
    @State private var tempSum: Double = 0
    @State private var tempSamples: Int = 0
    
    // Resultados y perfil final
    @State private var phaseResults: [PhaseResult] = []
    @State private var finalProfile: RoastProfile? = nil
    @State private var gameFinished: Bool = false
    
    // Timer
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Tueste")
                .font(.system(size: 28, weight: .bold))
            
            if !gameFinished {
                currentPhaseView
            } else {
                resultView
            }
            
            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            guard isRunning, !gameFinished else { return }
            elapsedInPhase += 0.2
            tempSum += currentTemp
            tempSamples += 1
        }
        .animation(.easeInOut, value: gameFinished)
    }
    
    // MARK: - Subvistas
    
    private var currentPhaseView: some View {
        let phase = phases[currentPhaseIndex]
        let idealRange = phase.idealTempRange
        
        return VStack(spacing: 16) {
            Text("Fase \(currentPhaseIndex + 1) de \(phases.count)")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(phase.displayName)
                .font(.title2.bold())
            
            Text(phase.description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            // Indicador de tiempo (el jugador puede alargar/acortar)
            VStack(spacing: 4) {
                Text("Tiempo en fase: \(Int(elapsedInPhase)) s")
                    .font(.subheadline)
                Text("Duración ideal aproximada: \(Int(phase.idealDuration)) s")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Slider de temperatura
            VStack(spacing: 8) {
                Slider(value: $currentTemp, in: 130...230, step: 1)
                HStack {
                    Text("Temperatura: \(Int(currentTemp)) °C")
                        .font(.body.monospacedDigit())
                    Spacer()
                    Text("Ideal: \(Int(idealRange.lowerBound))–\(Int(idealRange.upperBound)) °C")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Barra visual simple de “qué tan cerca” estás de la zona ideal
            VStack(alignment: .leading, spacing: 4) {
                Text("Proximidad a la zona ideal")
                    .font(.caption)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 10)
                        
                        // Zona ideal
                        let width = geo.size.width
                        let range = 230.0 - 130.0
                        let idealStart = (idealRange.lowerBound - 130.0) / range
                        let idealEnd = (idealRange.upperBound - 130.0) / range
                        
                        Capsule()
                            .fill(Color.green.opacity(0.4))
                            .frame(width: width * (idealEnd - idealStart),
                                   height: 10)
                            .offset(x: width * idealStart)
                        
                        // Posición actual
                        let currentPos = (currentTemp - 130.0) / range
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                            .offset(x: max(0, min(width - 18, width * currentPos - 9)))
                    }
                }
                .frame(height: 18)
            }
            
            // Controles
            HStack(spacing: 16) {
                Button(isRunning ? "Pausar" : (elapsedInPhase == 0 ? "Iniciar fase" : "Reanudar")) {
                    isRunning.toggle()
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.ka_coffee)
                .foregroundStyle(Color.ka_surface)
                .clipShape(Capsule())
                
                Button(currentPhaseIndex == phases.count - 1 ? "Finalizar tueste" : "Siguiente fase") {
                    endCurrentPhaseAndAdvance()
                }
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.ka_coffee)
                .foregroundStyle(Color.ka_surface)
                .clipShape(Capsule())
            }
        }
    }
    
    private var resultView: some View {
        VStack(spacing: 16) {
            
            if let profile = finalProfile {
                Text(profile.name)
                    .font(.title3.bold())
                
                Text(profile.summary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sabores:")
                        .font(.headline)
                    Text(profile.flavors.joined(separator: ", "))
                    
                    Text("Aromas:")
                        .font(.headline)
                        .padding(.top, 4)
                    Text(profile.aromas.joined(separator: ", "))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            Button("Continuar") {
                if let profile = finalProfile{
                    onFinish?(profile)
                }
            }
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.ka_coffee)
            .foregroundStyle(Color.ka_surface)
            .clipShape(Capsule())        }
    }
    
    // MARK: - Lógica de juego
    
    private func endCurrentPhaseAndAdvance() {
        isRunning = false
        
        let phase = phases[currentPhaseIndex]
        let average = tempSamples > 0 ? tempSum / Double(tempSamples) : currentTemp
        
        let result = PhaseResult(
            phase: phase,
            averageTemp: average,
            duration: elapsedInPhase
        )
        phaseResults.append(result)
        
        // Reset para la siguiente fase
        elapsedInPhase = 0
        tempSum = 0
        tempSamples = 0
        
        if currentPhaseIndex == phases.count - 1 {
            // Se acabaron las fases → calcular perfil
            finalProfile = evaluateRoastProfile(from: phaseResults)
            gameFinished = true
        } else {
            currentPhaseIndex += 1
            
            // Opcional: arrancar temp en el centro del rango ideal de la siguiente fase
            let nextPhase = phases[currentPhaseIndex]
            let ideal = nextPhase.idealTempRange
            currentTemp = (ideal.lowerBound + ideal.upperBound) / 2
        }
    }
    
    private func resetGame() {
        currentPhaseIndex = 0
        currentTemp = 150
        isRunning = false
        elapsedInPhase = 0
        tempSum = 0
        tempSamples = 0
        phaseResults = []
        finalProfile = nil
        gameFinished = false
    }
    
    // MARK: - Evaluación del perfil
    
    /// Evalúa los resultados y devuelve un perfil sencillo de tueste
    private func evaluateRoastProfile(from results: [PhaseResult]) -> RoastProfile {
        // Buscar resultados por fase
        func result(for phase: RoastPhase) -> PhaseResult? {
            return results.first(where: { $0.phase == phase })
        }
        
        let drying = result(for: .drying)
        let maillard = result(for: .maillard)
        let dev = result(for: .development)
        
        // Métricas súper sencillas
        let totalTime = results.reduce(0) { $0 + $1.duration }
        let devDuration = dev?.duration ?? 0
        let devTemp = dev?.averageTemp ?? 195
        
        // Evaluamos nivel de tueste con reglas muy simples
        let roastLevel: String
        if devTemp < 195 && devDuration < 50 {
            roastLevel = "Tueste ligero"
        } else if devTemp <= 205 && devDuration <= 80 {
            roastLevel = "Tueste medio"
        } else {
            roastLevel = "Tueste oscuro"
        }
        
        // Evaluar “balance” de Maillard
        var sweetness = "dulzor balanceado"
        if let m = maillard {
            if m.duration < m.phase.idealDuration * 0.7 {
                sweetness = "dulzor bajo, más acidez"
            } else if m.duration > m.phase.idealDuration * 1.3 {
                sweetness = "dulzor alto pero algo pesado"
            }
        }
        
        // Evaluar posible subdesarrollo / sobre-desarrollo
        var defectNote: String?
        if let d = drying, d.duration < d.phase.idealDuration * 0.6 {
            defectNote = "ligeras notas vegetales por secado rápido"
        } else if devTemp > 210 && devDuration > 70 {
            defectNote = "notas tostadas intensas, cercanas a quemado"
        }
        
        // Construir sabores y aromas
        var flavors: [String] = []
        var aromas: [String] = []
        
        switch roastLevel {
        case "Tueste ligero":
            flavors += ["cítricos", "frutas brillantes", "dulzor suave"]
            aromas += ["floral", "frutal"]
        case "Tueste medio":
            flavors += ["caramelo", "chocolate con leche", "frutos secos"]
            aromas += ["pan tostado", "almendra", "caramelo"]
        default: // oscuro
            flavors += ["chocolate amargo", "cacao intenso", "notas ahumadas"]
            aromas += ["humo suave", "carbón ligero", "cacao tostado"]
        }
        
        if sweetness.contains("bajo") {
            flavors.append("acidez marcada")
        }
        if let defect = defectNote {
            flavors.append(defect)
        }
        
        let summary = """
        \(roastLevel) con \(sweetness). Tiempo total de tueste: \(Int(totalTime)) s. \
        \nFase de desarrollo: \(Int(devDuration)) s a ~\(Int(devTemp)) °C.
        """
        
        return RoastProfile(
            name: roastLevel,
            summary: summary,
            flavors: flavors,
            aromas: aromas
        )
    }
}
