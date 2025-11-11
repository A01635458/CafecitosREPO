//
//  SpecialtyCoffeeView.swift
//  KaapehApp
//
//  Created by Alumno on 10/11/25.
// Por Ivan Ornelas Delgadillo A01384247

import SwiftUI

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
                Spacer()
            }
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.ka_surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }
}

private struct SCARatingCard: View {
    let score: Int
    var body: some View {
        VStack(spacing: 8) {
            Text("Clasificación SCA")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("\(score) / 100")
                .font(.system(size: 40, weight: .heavy))
                .foregroundStyle(Color.ka_coffee.opacity(0.8))
                .padding(.vertical, 4)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
            Text(score >= 80 ? "¡Café de Especialidad!" : "Grado Comercial")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .background(Color.ka_coffee)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .ka_coffee.opacity(0.4), radius: 8, y: 4)
        .padding(.horizontal, 20)
    }
}

struct CuppingLessonView: View {
    @State private var isFavorite = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 30) {
                
                LessonHeaderView(
                    imageURL: "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg",
                    title: "Cata Profesional: El Cupping",
                    subtitle: "Cómo el catador evalúa el sabor y la calidad del café",
                    isFavorite: $isFavorite
                )
                
                SCARatingCard(score: 87)
                
                LessonTextBlock(
                    title: "El Protocolo de Cata (Cupping)",
                    text: """
                    El cupping es el método estandarizado para evaluar y calificar la calidad del café. Los catadores profesionales (Q Graders) usan este protocolo para asignar una puntuación basada en 10 atributos clave.
                    """
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("10 Atributos de Calidad")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        MetricCard(title: "Fragancia/Aroma", value: "9/10", icon: "wind", color: .brown)
                        MetricCard(title: "Acidez", value: "8.5/10", icon: "drop.triangle.fill", color: .yellow)
                        MetricCard(title: "Cuerpo", value: "9/10", icon: "suit.club.fill", color: .gray)
                        MetricCard(title: "Sabor", value: "9.5/10", icon: "mouth.fill", color: .red)
                    }
                    .padding(.horizontal, 20)
                }
                
                FunFactGlassCard(text: "La 'Rueda de Sabores del Café' es la herramienta principal para identificar y comunicar los matices de sabor de un grano de forma universal.")
                
                AsyncImage(url: URL(string: "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg")) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 20)
                
                
                LessonTextBlock(
                    title: "Fases del Análisis",
                    text: """
                    1. **Fragancia:** En seco, antes de añadir agua.
                    2. **Aroma:** Después de añadir agua caliente (rompiendo la costra).
                    3. **Degustación (Slurping):** Aspiración ruidosa para rociar el café en toda la boca.
                    4. **Puntuación:** Evaluación en frío.
                    """
                )
                
                QuizWidget(
                    question: "¿Qué término describe la sensación de peso y textura del café en la boca?",
                    options: ["Acidez", "Cuerpo (Body)", "Postgusto"],
                    correctAnswer: 1
                )
                
                LessonFinishButton()

                Spacer().frame(height: 60)
            }
            .padding(.bottom, 40)
        }
        .background(Color.ka_bg.ignoresSafeArea())
    }
}
