//
//  GameOverView.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import SwiftUI

struct GameOverView: View {
    let finalScore: Int
    let advice: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("⏳ El juego ha terminado")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text("Puntuación final: \(finalScore)")
                .font(.title.bold())
                .foregroundColor(.ka_coffee)
            
            Text("Consejo de especialidad: \(advice)")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.ka_bg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button("Cerrar") {
                onClose()
            }
            .font(.title3.bold())
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.ka_coffee)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
