import SwiftUI
import SwiftData

@main
struct KaapehApp: App {
    // Crear un contenedor compartido (persistente)
    let container: ModelContainer

    init() {
<<<<<<< Updated upstream
        // configuración del modelo compartido
        let schema = Schema([NoteEntity.self])
=======
        let schema = Schema([CoffeePlant.self])
>>>>>>> Stashed changes
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        container = try! ModelContainer(for: schema, configurations: [configuration])
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
