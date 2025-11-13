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
                    title: "Del cacao a la especialidad",
                    subtitle: "Fermentación, secado y perfiles de sabor",
                    isFavorite: $isFavorite
                )
                
                LessonTextBlock(
                    title: "Procesos del grano",
                    text: """
                    La fermentación es esencial para el desarrollo del sabor y aroma en el café de especialidad. 
                    La duración y temperatura influyen directamente en el dulzor y la acidez.
                    """
                )

                LargeWidgetCard(
                    imageURL: "https://images.pexels.com/photos/894695/pexels-photo-894695.jpeg",
                    title: "Fermentación controlada",
                    description: "Un secado lento y constante asegura que los granos mantengan su estructura y no desarrollen sabores amargos."
                )

                FunFactGlassCard(text: "Un secado demasiado rápido puede provocar sabores desequilibrados y pérdida de aroma en el café final.")
                
                QuizWidget(
                    question: "¿Qué etapa define el perfil aromático del café?",
                    options: ["Fermentación", "Tueste", "Molido"],
                    correctAnswer: 0
                )
                
                LessonCameraSection(
                    instruction: "Fotografía un grano en proceso de fermentación para observar sus cambios de color y textura.",
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
