//
//  CameraGameView.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import SwiftUI

struct CameraGameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var game = CameraGameViewModel()
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var resultColor: Color = .green
    @State private var showGameOver = false
    @State private var finalTip = ""
    
    var body: some View {
        ZStack {
            CameraPreviewView(session: game.camera.session)
                .ignoresSafeArea()
                .opacity(showGameOver ? 0 : 1)

            if !showGameOver {
                VStack(spacing: 20) {
                    HStack {
                        Text("Puntos totales: \(game.score)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Tiempo faltante: \(game.timeLeft)s")
                            .font(.headline)
                            .foregroundColor(game.timeLeft <= 5 ? .red : .white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    HStack {
                        Button { dismiss() } label: {
                            Circle().fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "xmark").foregroundStyle(.white))
                        }
                        Spacer()
                        Button {
                            game.camera.flipCamera()
                        } label: {
                            Circle().fill(Color.black.opacity(0.5))
                                .frame(width: 44, height: 44)
                                .overlay(Image(systemName: "camera.rotate").foregroundStyle(.white))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("MISIÓN")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        if game.currentMissionType == .label {
                            Text("Encuentra un grano: \(game.currentMission.label)")
                                .font(.title3.bold())
                                .foregroundColor(.yellow)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Encuentra un grano: \(game.currentMission.trait)")
                                .font(.title3.bold())
                                .foregroundColor(.cyan)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    
                    Button {
                        game.camera.capture()
                    } label: {
                        ZStack {
                            Circle().stroke(.white.opacity(0.5), lineWidth: 4)
                                .frame(width: 85, height: 85)
                            Circle().fill(Color.ka_coffee)
                                .frame(width: 65, height: 65)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            
            if showResult {
                VStack(spacing: 12) {
                    Text(resultMessage)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding()

                    Button("Cerrar") {
                        withAnimation { showResult = false }
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .background(resultColor.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6)
                .transition(.scale)
            }
            if showGameOver {
                GameOverView(
                    finalScore: game.score,
                    advice: finalTip
                ) {
                    dismiss()
                }
                .background(.black.opacity(0.45))
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
        
        .onAppear {
            game.startGame()
            game.camera.start()
        }
        .onDisappear {
            game.camera.stop()
        }
        .onChange(of: game.lastScanMatch) { _, match in
            guard let match = match else { return }
            
            resultMessage = match.success ? "🎉 Correcto: \(match.message)" : "❌ Incorrecto: \(match.message)"
            resultColor = match.success ? .green : .red
            
            withAnimation { showResult = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { showResult = false }
            }
        }
        
        .onChange(of: game.gameEnded) { _, ended in
            if ended {
                game.camera.stop()
                finalTip = game.randomTip()
                        
                withAnimation(.easeIn(duration: 0.4)) {
                    showGameOver = true
                }
            }
        }
    }
}

#Preview {
    CameraGameView()
}
