//
//  ScansDetailView.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import SwiftUI

struct ScanDetailView: View {

    let scan: ScanModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(scan.label)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(Color.ka_coffee)

                        Text("Fecha: \(scan.formattedDate)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Que es este defecto?")
                            .font(.headline)
                            .foregroundColor(Color.ka_coffee)

                        Text(scan.info)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.85))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text("Existe un impacto para el cafe de especialidad?")
                            .font(.headline)
                            .foregroundColor(Color.ka_coffee)

                        Text(scan.specialtyimpact)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.85))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Text("Consejos de prevención del defecto")
                            .font(.headline)
                            .foregroundColor(Color.ka_coffee)

                        Text(scan.preventiontips)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.85))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                    }
                }
            

            }
            .padding(.horizontal)
            .padding(.top, 20)
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
