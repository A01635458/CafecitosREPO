//
//  VoiceOverService.swift
//  KaapehApp
//
//  Created by Alumno on 03/12/25.
//

import AVFoundation
import Foundation
import Combine

class VoiceOverService: ObservableObject {
    
    private let synthesizer: AVSpeechSynthesizer
    private var isFeatureEnabled: Bool

    init() {
        self.synthesizer = AVSpeechSynthesizer()
        self.isFeatureEnabled = false
    }
    
    func setIsEnabled(_ enabled: Bool) {
        self.isFeatureEnabled = enabled
    }

    func speak(_ text: String) {
        guard isFeatureEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = AVSpeechUtteranceMaximumSpeechRate * 0.45
        
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
