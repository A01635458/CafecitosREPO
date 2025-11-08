//
//  LearnView.swift
//  KaapehApp
//

import SwiftUI

struct LearnView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text("Aprende sobre el café")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 60)
                    .padding(.horizontal, 20)

                SectionBlock(title: "Variedades") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            VarietyCard(
                                name: "Arábica",
                                text: "Sabor suave, aromático y cultivado en altura.",
                                image: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg"
                            )
                            VarietyCard(
                                name: "Robusta",
                                text: "Más cafeína y sabor intenso, resistente al clima.",
                                image: "https://images.pexels.com/photos/4331452/pexels-photo-4331452.jpeg"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }

                SectionBlock(title: "Madurez del fruto") {
                    HStack(spacing: 16) {
                        MaturityCard(color: .green, stage: "Verde", desc: "Fruto inmaduro, no apto.")
                        MaturityCard(color: .yellow, stage: "Amarillo", desc: "En transición.")
                        MaturityCard(color: .red, stage: "Rojo", desc: "Maduro, listo para cosechar.")
                    }
                    .padding(.horizontal, 20)
                }

                SectionBlock(title: "Tueste") {
                    VStack(spacing: 12) {
                        RoastRow(color: .brown, name: "Claro", text: "Ácido y afrutado.")
                        RoastRow(color: .orange, name: "Medio", text: "Equilibrado y aromático.")
                        RoastRow(color: .black, name: "Oscuro", text: "Intenso y amargo.")
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.ka_bg)
    }
}


#Preview {
    LearnView()
}
