//
//  CameraView.swift
//  KaapehApp
//
//  Created by Luisa Cardona on 07/11/25.
//

//
//  CameraView.swift
//  KaapehApp
//

import SwiftUI

struct CameraView: View {
    @State private var showScanner = false
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 60)
                
                Image(systemName: "camera.metering.matrix")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .foregroundStyle(Color.ka_coffee)
                    .padding()
                
                Text("Escanear planta o grano")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                Text("Usa la cámara para identificar el tipo de defecto que tiene el grano y aprender mas sobre ella o juega a identificar el grano, para saber que tan rapido eres en identificar los defectos de varios granos.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .foregroundStyle(.black)
                
                Button {
                    showScanner = true
                } label: {
                    Label("Abrir cámara", systemImage: "camera.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.ka_coffee)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .ka_coffee.opacity(0.3), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 40)
                }
                
                Button {
                    showGame = true
                } label: {
                    Label("Iniciar juego de granos", systemImage: "gamecontroller.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.ka_coffee.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .ka_coffee.opacity(0.25), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .background(Color.ka_bg.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Camara")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .bold()
                }
            }
            
            .sheet(isPresented: $showScanner) {
                CameraScreen()
            }
            
            .sheet(isPresented: $showGame) {
                CameraGameView()
            }
        }
    }
}

#Preview {
    PreviewEnvironment {
        CameraView()
    }
}
