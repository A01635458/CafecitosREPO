import SwiftUI
import SwiftData

struct NewCoffeePlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedVarietal: CoffeeVarietal = .bourbon
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información de la planta") {
                    TextField("Nombre de la planta", text: $name)
                    
                    Picker("Tipo de café", selection: $selectedVarietal) {
                        ForEach(CoffeeVarietal.allCases) { varietal in
                            Text(varietal.displayName).tag(varietal)
                        }
                    }
                }
            }
            .navigationTitle("Nueva planta")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Crear") {
                        createPlant()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createPlant() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let plant = CoffeePlant(
            name: trimmedName,
            varietal: selectedVarietal.rawValue, // 👈 aquí guardas el tipo
            stage: .seed,
            stageStartedAt: .now,
            water: 50,
            light: 30
        )
        
        modelContext.insert(plant)
        try? modelContext.save()
        dismiss()
    }
}

