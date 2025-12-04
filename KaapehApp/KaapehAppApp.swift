import SwiftUI
import SwiftData

@main
struct KaapehApp: App {
    let container: ModelContainer
    init() {
        let schema = Schema([CoffeePlant.self, LessonEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            let url = configuration.url
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



