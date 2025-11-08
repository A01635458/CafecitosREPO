//import SwiftUI
//
//struct HomeView: View {
//    var body: some View {
//        NavigationStack {
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 28) {
//                    
//                    // MARK: - Encabezado de progreso general
//                    VStack(alignment: .leading, spacing: 14) {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text("Hola!")
//                                    .font(.system(size: 24, weight: .bold))
//                                Text("Aquí está tu progreso actual ")
//                                    .font(.system(size: 14))
//                                    .foregroundStyle(.secondary)
//                            }
//                            Spacer()
//                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg")) { img in
//                                img.resizable().scaledToFill()
//                            } placeholder: { Color.gray.opacity(0.2) }
//                                .frame(width: 55, height: 55)
//                                .clipShape(Circle())
//                        }
//                        
//                        VStack(alignment: .leading, spacing: 6) {
//                            HStack {
//                                Text("Progreso total")
//                                    .font(.system(size: 14, weight: .semibold))
//                                Spacer()
//                                Text("65%")
//                                    .font(.system(size: 14, weight: .medium))
//                                    .foregroundStyle(.secondary)
//                            }
//                            ProgressView(value: 0.65)
//                                .tint(.ka_coffee)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 40)
//                    
//                    // MARK: - Fun Fact del Día
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text(" Fun Fact del Día")
//                            .font(.system(size: 18, weight: .semibold))
//                        Text("¿Sabías que el café fue descubierto por un pastor etíope llamado Kaldi, que notó que sus cabras se volvían más activas después de comer frutos de café?")
//                            .font(.system(size: 15))
//                            .foregroundStyle(.secondary)
//                    }
//                    .padding(20)
//                    .background(Color.ka_surface)
//                    .clipShape(RoundedRectangle(cornerRadius: 18))
//                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
//                    .padding(.horizontal, 20)
//                    
//                    // MARK: - Próxima lección recomendada
//                    VStack(alignment: .leading, spacing: 14) {
//                        Text("Siguiente lección recomendada")
//                            .font(.system(size: 20, weight: .bold))
//                            .padding(.horizontal, 20)
//                        
//                        NavigationLink(destination: CacaoLessonView()) {
//                            ZStack(alignment: .bottomLeading) {
//                                AsyncImage(url: URL(string: "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg")) { img in
//                                    img.resizable().scaledToFill()
//                                } placeholder: { Color.gray.opacity(0.2) }
//                                .frame(height: 200)
//                                .clipShape(RoundedRectangle(cornerRadius: 20))
//                                
//                                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
//                                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                                
//                                VStack(alignment: .leading, spacing: 6) {
//                                    Text("Del cacao a la especialidad")
//                                        .font(.system(size: 20, weight: .bold))
//                                        .foregroundStyle(.white)
//                                    Text("Aprende cómo el procesamiento influye en el sabor y la calidad del grano.")
//                                        .font(.system(size: 14))
//                                        .foregroundStyle(.white.opacity(0.9))
//                                }
//                                .padding(20)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    
//                    // MARK: - Resumen de progreso por módulos
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Resumen de tus módulos")
//                            .font(.system(size: 20, weight: .bold))
//                            .padding(.horizontal, 20)
//                        
//                        VStack(spacing: 14) {
//                            ModuleRow(title: " La planta del café", progress: 0.9)
//                            ModuleRow(title: "Del cacao a la especialidad", progress: 0.45)
//                            ModuleRow(title: "Tueste y aroma", progress: 0.2)
//                            ModuleRow(title: "Cata y especialidades", progress: 0.6)
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    
//                    // MARK: - Ver temario completo
//                    VStack(alignment: .center) {
//                        NavigationLink(destination: LearnView()) {
//                            Label("Ver temario completo", systemImage: "book")
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundStyle(.white)
//                                .padding(.vertical, 14)
//                                .frame(maxWidth: .infinity)
//                                .background(Color.ka_coffee)
//                                .clipShape(RoundedRectangle(cornerRadius: 16))
//                        }
//                        .padding(.horizontal, 20)
//                    }
//
//                    Spacer().frame(height: 60)
//                }
//            }
//            .background(Color.ka_bg.ignoresSafeArea())
//            .navigationTitle("")
//            .navigationBarHidden(true)
//        }
//    }
//}
//
//// MARK: - Componente de módulo
//private struct ModuleRow: View {
//    let title: String
//    let progress: Double
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                Text(title)
//                    .font(.system(size: 16, weight: .semibold))
//                Spacer()
//                Text("\(Int(progress * 100))%")
//                    .font(.system(size: 13))
//                    .foregroundStyle(.secondary)
//            }
//            ProgressView(value: progress)
//                .tint(.ka_coffee)
//        }
//        .padding()
//        .background(Color.ka_surface)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
//    }
//}
//
//#Preview {
//    HomeView()
//}


//
//  HomeView.swift
//  KaapehApp
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var animatedProgress: Double = 0.0

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    // MARK: - Encabezado de progreso general
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hola!")
                                    .font(.system(size: 24, weight: .bold))
                                Text("Aquí está tu progreso actual")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg")) { img in
                                img.resizable().scaledToFill()
                            } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Progreso total")
                                    .font(.system(size: 14, weight: .semibold))
                                Spacer()
                                Text("\(Int(animatedProgress * 100))%")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: animatedProgress)
                                .tint(.ka_coffee)
                                .animation(.easeOut(duration: 1.0), value: animatedProgress)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    // MARK: - Fun Fact del Día
                    VStack(alignment: .leading, spacing: 12) {
                        Text(" Fun Fact del Día")
                            .font(.system(size: 18, weight: .semibold))
                        Text("¿Sabías que el café fue descubierto por un pastor etíope llamado Kaldi, que notó que sus cabras se volvían más activas después de comer frutos de café?")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color.ka_surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Próxima lección recomendada
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Siguiente lección recomendada")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        NavigationLink(destination: CacaoLessonView()) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg")) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: { Color.gray.opacity(0.2) }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Del cacao a la especialidad")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Aprende cómo el procesamiento influye en el sabor y la calidad del grano.")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                .padding(20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Resumen de progreso por módulos
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resumen de tus módulos")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 14) {
                            ModuleRow(title: "La planta del café", progress: 0.9)
                            ModuleRow(title: " Del cacao a la especialidad", progress: 0.45)
                            ModuleRow(title: " Tueste y aroma", progress: 0.2)
                            ModuleRow(title: "Cata y especialidades", progress: 0.6)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Ver temario completo
                    VStack(alignment: .center) {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                selectedTab = 2 // Cambia a “Aprender”
                            }
                        } label: {
                            Label("Ver temario completo", systemImage: "book.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(Color.ka_coffee)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .ka_coffee.opacity(0.3), radius: 5, y: 3)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 60)
                }
            }
            .background(Color.ka_bg.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                // Animación de carga de progreso
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 1.2)) {
                        animatedProgress = 0.65
                    }
                }
            }
        }
    }
}

// MARK: - Componente de módulo
private struct ModuleRow: View {
    let title: String
    let progress: Double
    @State private var animatedProgress: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: animatedProgress)
                .tint(.ka_coffee)
                .animation(.easeOut(duration: 1.0), value: animatedProgress)
        }
        .padding()
        .background(Color.ka_surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(1))
}
