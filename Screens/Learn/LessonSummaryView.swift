//
//  LessonSummaryView.swift
//  KaapehApp
//
//  Created by Alumno on 02/12/25.
//

import SwiftUI
import Foundation

struct MetricCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
    let color: Color
}

struct SummaryContent {
    let introAndTopics: String
    let conclusion: String
    let tips: [String]
    let moduleMetrics: [MetricCard]
    let inactiveLessonsList: String
}

struct MetricView: View {
    let metric: MetricCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: metric.icon)
                    .font(.title2)
                    .foregroundStyle(metric.color)
                Spacer()
            }
            Text(metric.value)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundStyle(.black)
            Text(metric.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.gray)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(metric.color.opacity(0.6), lineWidth: 2)
        )
    }
}


struct LessonSummaryView: View {
    @ObservedObject var apiService = CafecitosAPIService.shared
    let moduleTitle: String
    
    var filteredLessons: [LessonDTO] {
        return apiService.lessons.sorted(by: { $0.sort_order < $1.sort_order })
    }
    
    var body: some View {
        Group {
            if apiService.isLoading && filteredLessons.isEmpty {
                ProgressView("Cargando datos premium...")
            } else if let error = apiService.errorMessage, filteredLessons.isEmpty {
                VStack {
                    Text("Error al cargar los datos: \(error)").foregroundColor(.red)
                    Button("Reintentar") { Task { await apiService.fetchLessons() } }
                }
                .padding()
            } else {
                let summaryData = generateSimulatedSummary(from: filteredLessons, moduleTitle: moduleTitle)
                
                ZStack {
                    Color("ka_bg").ignoresSafeArea()
                    
                    LinearGradient(colors: [Color("ka_coffee").opacity(0.8), Color("ka_coffee").opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 300)
                        .ignoresSafeArea(edges: .top)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color("ka_coffee"))
                                    Text("Módulo de Estudio")
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                
                                Text(moduleTitle)
                                    .font(.system(size: 38, weight: .heavy, design: .serif))
                                    .foregroundStyle(.black)
                                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 40)
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Análisis de Datos Globales de Lecciones")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                                    .padding(.leading, 5)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    ForEach(summaryData.moduleMetrics) { metric in
                                        MetricView(metric: metric)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 20) {
                                
                                HStack {
                                    Image(systemName: "mug.fill")
                                        .foregroundStyle(.teal)
                                    Text("Temario Activo (Lecciones Globales)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                }
                                .padding(.bottom, 5)
                                
                                Text(summaryData.introAndTopics)
                                    .font(.body)
                                    .lineSpacing(6)
                                    .foregroundColor(.black.opacity(0.85))
                                
                                if !summaryData.inactiveLessonsList.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        
                                        Divider().padding(.vertical, 5)
                                        
                                        Text("Lecciones Pendientes (Inactivas)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.orange)
                                        
                                        Text("Estas lecciones aún no están disponibles o fueron deshabilitadas:\n\(summaryData.inactiveLessonsList)")
                                            .font(.subheadline)
                                            .lineSpacing(4)
                                            .foregroundColor(.gray)
                                            .padding(.leading, 10)
                                    }
                                }
                                
                                Divider().padding(.vertical, 10)
                                
                                Text("✨ Conclusión del Módulo")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("ka_coffee"))
                                
                                Text(summaryData.conclusion)
                                    .font(.subheadline)
                                    .italic()
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("🛠️ Consejos Adicionales")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("ka_coffee"))
                                    
                                    ForEach(summaryData.tips, id: \.self) { tip in
                                        HStack(alignment: .top) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(Color("ka_coffee"))
                                                .padding(.top, 4)
                                            Text(tip)
                                                .font(.subheadline)
                                                .foregroundColor(.black.opacity(0.9))
                                        }
                                    }
                                }
                                .padding(15)
                                .background(Color("ka_coffee").opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                // 🗑️ Se elimina la frase sobre contenido estático
                                
                            }
                            .padding(25)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            if apiService.lessons.isEmpty {
                Task {
                    await apiService.fetchLessons()
                }
            }
        }
    }
    
    private func generateSimulatedSummary(from lessons: [LessonDTO], moduleTitle: String) -> SummaryContent {
        
        let activeLessons = lessons.filter { $0.is_active ?? false }
        let inactiveLessons = lessons.filter { !($0.is_active ?? false) }
        
        let totalActiveCount = activeLessons.count
        let totalInactiveCount = inactiveLessons.count
        
        let activeTitlesList = activeLessons.map { $0.title }.enumerated().map { (index, title) in
            return "📘 \(title)"
        }.joined(separator: "\n")
        
        // 🗑️ Se eliminan los dobles asteriscos de moduleTitle y "total"
        let intro = "Este módulo de \(moduleTitle) abarca un total de \(totalActiveCount) lecciones activas en el sistema. Los siguientes son los puntos clave que componen el temario global:\n\n\(activeTitlesList)"
        
        let inactiveTitlesList = inactiveLessons.map { $0.title }.enumerated().map { (index, title) in
            return "❌ \(title)"
        }.joined(separator: "\n")
        
        let conclusion: String
        var tips: [String] = []
        
        if moduleTitle.localizedCaseInsensitiveContains("Cata") || moduleTitle.localizedCaseInsensitiveContains("especialidades") {
            conclusion = "El dominio de este módulo te permitirá desarrollar el Paladar Crítico Profesional, aplicando el Protocolo de Cata SCA a cualquier café."
            tips.append("Practica el 'Cupping' (cata profesional) usando la rueda de sabores del café para identificar matices específicos y expandir tu vocabulario sensorial.")
            tips.append("Mantén un diario de cata para registrar tus notas de sabor, aroma y cuerpo, mejorando tu memoria sensorial con cada sesión.")
        } else if moduleTitle.localizedCaseInsensitiveContains("Tueste") || moduleTitle.localizedCaseInsensitiveContains("aroma") {
            //Consejos ajustados para principiantes
            conclusion = "El foco principal es entender cómo el tueste afecta el sabor. La clave es optimizar el tueste para que el café sepa mejor en tu método de preparación (por ejemplo, prensa francesa o goteo)."
            tips.append("Empieza conociendo los puntos básicos: el 'primer crack' (cuando el grano revienta por primera vez) y el 'segundo crack'. Son las claves para saber qué tan tostado está tu café.")
            tips.append("Si compras café, busca la fecha de tueste, no solo la de caducidad. Un tueste reciente asegura el mejor aroma y sabor. Si tuestas tú, anota las temperaturas y tiempos.")
        } else {
            conclusion = "La conclusión es que el foco principal es el desarrollo de habilidades de evaluación crítica y la comprensión del ciclo de valor del café."
            tips.append("Revisa las lecciones con mayor contenido para reforzar los conceptos fundamentales.")
            tips.append("Intenta relacionar los conceptos de diferentes lecciones; por ejemplo, cómo el procesamiento afecta el perfil de cata.")
        }
        
        let complexity: (String, Color) = totalActiveCount >= 5 ? ("Avanzada", .red) : ("Intermedia", .purple)
        
        var focusArea = "Teoría General"
        if moduleTitle.localizedCaseInsensitiveContains("Cata") {
            focusArea = "Sensorial"
        } else if moduleTitle.localizedCaseInsensitiveContains("Tueste") {
            focusArea = "Química/Procesos"
        } else if moduleTitle.localizedCaseInsensitiveContains("planta") || moduleTitle.localizedCaseInsensitiveContains("cacao") {
            focusArea = "Origen/Botánica"
        }
        
        let estimatedTime = String(format: "%.1f Hrs", Double(totalActiveCount) * 0.5)
        
        let metrics: [MetricCard] = [
            MetricCard(icon: "list.number", title: "Lecciones Activas", value: "\(totalActiveCount)", color: .teal),
            MetricCard(icon: "archivebox.fill", title: "Lecciones Inactivas", value: "\(totalInactiveCount)", color: .orange),
            MetricCard(icon: "star.fill", title: "Dificultad Estimada", value: complexity.0, color: complexity.1),
            MetricCard(icon: "target", title: "Enfoque Principal", value: focusArea, color: .blue),
            MetricCard(icon: "clock.fill", title: "Tiempo Estimado", value: estimatedTime, color: .green)
        ]
        
        return SummaryContent(
            introAndTopics: intro,
            conclusion: conclusion,
            tips: tips,
            moduleMetrics: metrics,
            inactiveLessonsList: inactiveTitlesList
        )
    }
}

