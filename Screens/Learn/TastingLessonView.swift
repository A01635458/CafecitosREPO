import SwiftUI

struct TastingLessonView: View {
    @State private var showCamera = false
    @State private var isFavorite = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                LessonHeaderView(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "Cata sensorial",
                    subtitle: "Explorando aromas y sabores del café",
                    isFavorite: $isFavorite
                )

                LessonTextBlock(
                    title: "Análisis sensorial",
                    text: """
                    La cata sensorial evalúa el aroma, sabor, cuerpo y acidez del café. 
                    Los catadores identifican notas como chocolate, frutos rojos o flores.
                    """
                )

                LargeWidgetCard(
                    imageURL: "https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg",
                    title: "Técnica de cata",
                    description: "Durante la cata se sorbe el café para airearlo y distribuir los sabores uniformemente."
                )

                FunFactGlassCard(text: "El protocolo oficial de la SCA usa 8.25 g de café por 150 ml de agua para mantener consistencia en las catas.")
                
                QuizWidget(
                    question: "¿Qué característica describe la sensación táctil en boca?",
                    options: ["Aroma", "Cuerpo", "Acidez"],
                    correctAnswer: 1
                )

                LessonCameraSection(
                    instruction: "Toma una foto de una taza servida para analizar la crema y el color del café.",
                    showCamera: $showCamera
                )

                LessonFinishButton()
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showCamera) { CameraScreen() }
        .background(Color.ka_bg.ignoresSafeArea())
    }
}

#Preview {
    TastingLessonView()
}
