//
//  CacaoLessonView.swift
//  KaapehApp
//
//  Created by Luisa Cardona on 07/11/25.
//

import SwiftUI

struct CacaoLessonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image("cacao")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text("Del cacao a la especialidad")
                    .font(.system(size: 24, weight: .bold))
                Text("El proceso del café de especialidad comparte con el cacao la importancia del **origen, la fermentación y el tueste**. Cada etapa define la calidad final de la bebida. La trazabilidad y los métodos de procesamiento son esenciales para lograr un perfil de taza único.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Cacao y Especialidad")
        .background(Color.ka_bg)
    }
}
//