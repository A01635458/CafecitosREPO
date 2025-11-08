//
//  PlantLessonView.swift
//  KaapehApp
//
//  Created by Luisa Cardona on 07/11/25.
//

import Foundation

import SwiftUI

struct PlantLessonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image("coffeeplant")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text("Iniciando con la planta")
                    .font(.system(size: 24, weight: .bold))
                Text("El cafeto es una planta tropical que crece en zonas de altura. Existen dos especies principales: **Coffea Arabica** y **Coffea Canephora (Robusta)**. La primera produce cafés más aromáticos y suaves, mientras que la segunda da sabores más fuertes y con mayor cafeína.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("La Planta")
        .background(Color.ka_bg)
    }
}
