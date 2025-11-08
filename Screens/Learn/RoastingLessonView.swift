import SwiftUI

struct RoastingLessonView: View {
    @State private var showCamera = false
    @State private var isFavorite = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                LessonHeaderView(
                    imageURL: "https://images.pexels.com/photos/302896/pexels-photo-302896.jpeg",
                    title: "Tueste y aroma",
                    subtitle: "El arte de transformar el grano en sabor",
                    isFavorite: $isFavorite
                )

                LessonTextBlock(
                    title: "Niveles de tueste",
                    text: """
                    El tueste del café convierte los granos verdes en marrones aromáticos. 
                    A medida que se calientan, los azúcares caramelizan y los ácidos se suavizan.
                    """
                )

                LargeWidgetCard(
                    imageURL: "https://images.pexels.com/photos/1695052/pexels-photo-1695052.jpeg",
                    title: "Puntos de ruptura",
                    description: "El primer crack marca la liberación de vapor y gases, un punto clave para definir el perfil del tueste."
                )

                FunFactGlassCard(text: "El primer crack ocurre a 196°C y define la textura y aroma final del café.")
                
                QuizWidget(
                    question: "¿Qué ocurre si el tueste se prolonga demasiado?",
                    options: ["Se intensifica el aroma", "Se pierde acidez y se quema el grano", "No cambia el sabor"],
                    correctAnswer: 1
                )

                LessonCameraSection(
                    instruction: "Toma una foto de granos con distintos niveles de tueste e identifica sus diferencias de color.",
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
