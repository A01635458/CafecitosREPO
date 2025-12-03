//leccion uno
//clasificacion de defectos
//tenga area para el quiz todo y lea de

import SwiftUI

struct CacaoLessonView: View {
    @State private var showCamera = false
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 35) {
                LessonHeaderView(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "El Viaje del Café de Especialidad",
                    subtitle: "Fermentación, Tueste y el Perfil de Taza",
                    isFavorite: $isFavorite
                )
                
                LessonTextBlock(
                    title: "Procesos Húmedos y Secos del Grano",
                    text: """
                    La fermentación es clave para el sabor del café, ¡no solo para el vino! En los procesos naturales secos, el grano se seca dentro de la cereza, dándole sabores más frutales. En los lavados húmedos, se quita la cereza antes de secar, resultando en sabores más limpios y ácidos.
                    """
                )

                LargeWidgetCard(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "El Tueste: De Verde a Marrón",
                    description: "El tueste es lo que libera los aromas. Un tueste ligero mantiene la acidez y las notas frutales, mientras que un tueste oscuro desarrolla sabores a chocolate y nueces, con menos acidez. Es un balance delicado para el sabor final."
                )

                FunFactGlassCard(text: "Un café se considera de 'especialidad' si obtiene 80 puntos o más en una escala de 100 por catadores expertos. ¡Es un estándar de calidad global!")
                
                QuizWidget(
                    question: "¿Qué proceso de café tiende a dar sabores más intensos y frutales?",
                    options: ["Lavado Húmedo", "Tueste Oscuro", "Natural Seco"],
                    correctAnswer: 2
                )
                
                LessonCameraSection(
                    instruction: "Aprende a diferenciar! Fotografía tres granos de café: uno sin tostar verde, uno de tueste claro y uno de tueste oscuro.",
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
    CacaoLessonView()
}
