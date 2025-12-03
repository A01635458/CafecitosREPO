//
//  LearnComponents.swift
//  KaapehApp
//

import SwiftUI

// MARK: - Header de cada lección
struct LessonHeaderView: View {
    let imageURL: String
    let title: String
    let subtitle: String
   
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageURL)) { img in
                img.resizable().scaledToFill()
            } placeholder: { Color.gray.opacity(0.2) }
            .frame(height: 260)
            .clipped()
            
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .center, endPoint: .bottom)
                .frame(height: 260)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .overlay(alignment: .topTrailing) {
          
        }
    }
}

// MARK: - Texto principal
struct LessonTextBlock: View {
    let title: String
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Fun Fact con blur
struct FunFactGlassCard: View {
    let text: String

    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Dato curioso")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.ka_coffee)
                }
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

// MARK: - Widget grande de imagen
struct LargeWidgetCard: View {
    let imageURL: String
    let title: String
    let description: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageURL)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            LinearGradient(colors: [.black.opacity(0), .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 6)
    }
}

// MARK: - Quiz
struct QuizWidget: View {
    let question: String
    let options: [String]
    let correctAnswer: Int
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quiz rápido")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.ka_coffee)
            Text(question)
                .font(.system(size: 16))
                .foregroundStyle(.black)
            
            ForEach(options.indices, id: \.self) { i in
                Button {
                    selectedIndex = i
                } label: {
                    HStack {
                        Text(options[i])
                            .font(.system(size: 15))
                        Spacer()
                        if selectedIndex == i {
                            Image(systemName: i == correctAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(i == correctAnswer ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding()
        .background(Color.ka_surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        .padding(.horizontal, 20)
    }
}

// MARK: - Ejercicio con cámara
struct LessonCameraSection: View {
    let instruction: String
    @Binding var showCamera: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ejercicio práctico")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            Text(instruction)
                .foregroundStyle(.black)
            Button {
                showCamera = true
            } label: {
                Label("Abrir cámara", systemImage: "camera.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ka_coffee)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Finalizar
struct LessonFinishButton: View {
    var body: some View {
        Button {
            // Acción final
        } label: {
            Text("Finalizar lección")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.ka_coffee)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.ka_surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Utilidad blur
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
