import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Encabezado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temario de lecciones")
                            .font(.system(size: 30, weight: .bold))
                        Text("Desde el cultivo hasta la taza")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)

                    // MARK: - Lección 1
                    LessonNavigationCard(
                        title: "La planta del café",
                        subtitle: "Origen, variedades y anatomía del cafeto",
                        imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg", // planta con cerezas
                        progress: 0.8,
                        destination: PlantLessonView()
                    )

                    // MARK: - Lección 2
                    LessonNavigationCard(
                        title: "Del cacao a la especialidad",
                        subtitle: "Fermentación y secado del café",
                        imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg", // granos secándose
                        progress: 0.4,
                        destination: CacaoLessonView()
                    )

                    // MARK: - Lección 3
                    LessonNavigationCard(
                        title: "Tueste y aroma",
                        subtitle: "Transformación del grano en sabor",
                        imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg", // tueste en proceso
                        progress: 0.2,
                        destination: RoastingLessonView()
                    )

                    // MARK: - Lección 4
                    LessonNavigationCard(
                        title: "Cata sensorial",
                        subtitle: "Explorando aromas y sabores",
                        imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg", // cata profesional
                        progress: 0.6,
                        destination: TastingLessonView()
                    )
                }
                .padding(.bottom, 80)
            }
            .background(Color.ka_bg)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Lesson Card
struct LessonNavigationCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let imageURL: String
    let progress: Double
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: imageURL)) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 230)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                LinearGradient(colors: [.clear, .black.opacity(0.6)],
                               startPoint: .center, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                    
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                }
                .padding(20)
            }
            .padding(.horizontal, 20)
            .shadow(color: .black.opacity(0.15), radius: 8, y: 6)
        }
    }
}
