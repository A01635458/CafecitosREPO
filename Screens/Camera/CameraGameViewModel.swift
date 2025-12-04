//
//  CameraGameViewModel.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import SwiftUI
import Combine

enum MissionType { case label, trait }

@MainActor
final class CameraGameViewModel: ObservableObject {

    @Published var score = 0
    @Published var timeLeft = 30
    @Published var currentMission = CoffeeMission(label: "agrio", trait: "fermentado")
    @Published var lastScanMatch: ScanResult?
    @Published var currentMissionType: MissionType = .label
    @Published var gameEnded = false
    
    let camera = CameraModel()
    
    let coffeeTips: [String] = [
        "Los granos defectuosos afectan directamente la taza: evita los negros o inmaduros.",
        "El café de especialidad se clasifica eliminando defectos físicos antes del tueste.",
        "Los granos veteados indican problemas de secado: afectan la dulzura del café.",
        "Los granos cereza seca son comunes en procesos mal depulpados.",
        "Los granos 'esponjosos' muestran secado acelerado: generan notas vegetales.",
        "Un grano 'fogueado' fue expuesto a calor excesivo durante el secado.",
        "La clasificación manual mejora la calidad final antes de la exportación."
    ]
    
    private var timerNumber: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    
    private let missions: [CoffeeMission] = [
        CoffeeMission(label: "agrio", trait: "ácido"),
        CoffeeMission(label: "cereza seca", trait: "con cáscara seca y roja"),
        CoffeeMission(label: "conchas", trait: "con un hueco o vacio"),
        CoffeeMission(label: "esponjoso", trait: "que se seco rápido"),
        CoffeeMission(label: "fogueado", trait: "quemado"),
        CoffeeMission(label: "veteado", trait: "manchado y con líneas internas"),
        CoffeeMission(label: "cafeblanco", trait: "con falta de color"),
        CoffeeMission(label: "cafeinmaduro", trait: "verde"),
        CoffeeMission(label: "cafenegro", trait: "oscuro y sobrefermentado"),
        CoffeeMission(label: "dañoporhongo", trait: "mohoso y fungoso")
    ]
    
    init() {
        camera.$detectedLabel
            .sink { [weak self] label in
                guard let self, let detected = label else { return }
                self.processScan(detected)
            }
            .store(in: &cancellables)
    }
    
    
    func startGame() {
        score = 0
        timeLeft = 30
        newMission()

        timerNumber?.cancel()

        timerNumber = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.timeLeft -= 1
                if self.timeLeft <= 0 {
                    self.timerNumber?.cancel()
                    self.camera.stop()
                    self.gameEnded = true
                }
            }
    }
    
    func newMission() {
        currentMission = missions.randomElement()!
        currentMissionType = Bool.random() ? .label : .trait
    }
    
    func processScan(_ detected: String) {
        let scanItem = detected.lowercased()
        
        if scanItem == currentMission.label.lowercased() {
            score += 10
            lastScanMatch = ScanResult(
                success: true,
                message: "¡Correcto! Encontraste un grano \(currentMission.label)."
            )
            newMission()
        } else {
            score -= 5
            lastScanMatch = ScanResult(
                success: false,
                message: "Era \(scanItem), pero debías encontrar \(currentMission.label)."
            )
        }
    }
    
    func randomTip() -> String {
        coffeeTips.randomElement() ?? "El café de especialidad comienza con una buena selección del grano."
    }
}
