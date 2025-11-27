import SwiftUI
import SwiftData

@main
struct KaapehApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([NoteEntity.self, CoffeePlant.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // ⚠️ SOLO PARA DESARROLLO:
            // si la migración falla, borramos el store y lo recreamos
            let url = configuration.url   // 👈 ya no es optional
            try? FileManager.default.removeItem(at: url)
            
            container = try! ModelContainer(for: schema, configurations: [configuration])
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
        .modelContainer(container)
    }
}

