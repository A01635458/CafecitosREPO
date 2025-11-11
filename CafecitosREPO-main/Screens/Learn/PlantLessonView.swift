import SwiftUI

struct PlantLessonView: View {
    @State private var showCamera = false
    @State private var isFavorite = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                LessonHeaderView(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "La planta del café",
                    subtitle: "Origen, variedades y anatomía del cafeto",
                    isFavorite: $isFavorite
                )

                LessonTextBlock(
                    title: "Estructura del cafeto",
                    text: """
                    El cafeto es una planta perenne con hojas verdes brillantes y frutos llamados cerezas, que albergan los granos de café.

                    Las variedades más comunes son Arábica y Robusta, con perfiles de sabor y resistencia distintos.
                    """
                )

                LargeWidgetCard(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "Crecimiento y floración",
                    description: """
                    Las flores vfelnwrlivkklw  del cafeto duran solo unos días, pero marcan el inicio del desarrollo de los frutos.

                    La maduración puede tardar de 6 a 9 meses, dependiendo del clima y la altitud.
                    """
                )

                FunFactGlassCard(text: "El café Arábica representa más del 60% de la producción mundial, aunque es más sensible al clima que la Robusta.")

                QuizWidget(
                    question: "¿Cuánto tarda en madurar un fruto del cafeto?",
                    options: ["3 a 4 meses", "6 a 9 meses", "Más de 1 año"],
                    correctAnswer: 1
                )

                LessonCameraSection(
                    instruction: "Toma una foto de una planta de café o sus hojas para identificar su variedad.",
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
