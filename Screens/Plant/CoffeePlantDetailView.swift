import SwiftUI
import SwiftData

// MARK: - Detail View

struct CoffeePlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var plant: CoffeePlant
    
    @State private var showDeleteAlert = false
    @State private var showRenameSheet = false
    @State private var newName: String = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Text("Estado actual: \(plant.stage.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            
            // Card principal de planta
            Card {
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color(red: 0.93, green: 0.86, blue: 0.74))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.ka_coffee)
                        )
                    
                    Text(plant.stage.displayName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    // Progreso de la etapa actual (tiempo)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progreso de la etapa")
                            .font(.subheadline)
                        ProgressView(value: plant.stageProgress)
                    }
                    .padding(.top, 4)
                    
                    // Estado de riego y luz
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Riego: \(plant.water)% (\(waterDescription(plant.water)))")
                                .font(.subheadline)
                            ProgressView(value: Double(plant.water), total: 100)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Luz: \(plant.light)% (\(lightDescription(plant.light)))")
                                .font(.subheadline)
                            ProgressView(value: Double(plant.light), total: 100)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Indicador de si cumple requisitos para avanzar
                    if plant.environmentRequirementsMet {
                        Text("✅ Requisitos de riego y luz cumplidos")
                            .font(.footnote)
                            .foregroundStyle(.green)
                    } else {
                        Text("⚠️ Ajusta riego o luz para poder avanzar")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 20)
            
            // Botones de acción principales
            HStack(spacing: 12) {
                // Restar agua
                Button {
                    removeWater()
                } label: {
                    Label("Quitar agua", systemImage: "drop.triangle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.ka_coffee)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Sumar agua
                Button {
                    water()
                } label: {
                    Label("Regar", systemImage: "drop.fill")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.ka_coffee)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Luz
                Button {
                    cycleLight()
                } label: {
                    Label("\(lightDescription(plant.light))", systemImage: "sun.max.fill")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.ka_surface)
                        .foregroundStyle(Color.ka_coffee)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.ka_coffee.opacity(0.25), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)


            
            // Botón para intentar avanzar de estado (usa la lógica de requisitos)
            Button {
                advanceStage()
            } label: {
                Label("Actualizar/avanzar estado", systemImage: "arrow.right.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.ka_surface)
                    .foregroundStyle(Color.ka_coffee)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ka_coffee.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .onAppear {
            // Al abrir, intentamos actualizar la etapa según el tiempo y requisitos
            plant.updateStageIfNeeded()
            try? modelContext.save()
        }
        // MARK: - Toolbar con menú (...)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Cambiar nombre", systemImage: "pencil") {
                        newName = plant.name
                        showRenameSheet = true
                    }
                    
                    Button("Eliminar planta", systemImage: "trash", role: .destructive) {
                        showDeleteAlert = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .semibold))
                }
            }
        }
        // MARK: - Alert eliminar planta
        .alert("¿Eliminar planta?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                deletePlant()
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        // MARK: - Sheet cambiar nombre
        .sheet(isPresented: $showRenameSheet) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Cambiar nombre")
                        .font(.system(size: 20, weight: .bold))
                    
                    TextField("Nuevo nombre", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 20)
                    
                    Button {
                        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        plant.name = trimmed
                        showRenameSheet = false
                        try? modelContext.save()
                    } label: {
                        Text("Guardar")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.ka_coffee)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.top, 32)
                .background(Color.ka_bg.ignoresSafeArea())
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") {
                            showRenameSheet = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func water() {
        // Usa el método del modelo para sumar agua
        plant.waterPlant(amount: 10)
        try? modelContext.save()
    }
    
    private func removeWater() {
        plant.water = max(0, plant.water - 10)
        plant.lastWaterUpdate = .now
        try? modelContext.save()
    }

    
    private func cycleLight() {
        // Ciclo simple: sombra -> parcial -> sol -> sombra, usando valores de 0–100
        let current = plant.light
        
        let nextValue: Int
        switch current {
        case 0..<40:
            nextValue = 55   // sombra parcial
        case 40..<75:
            nextValue = 85   // sol fuerte
        default:
            nextValue = 25   // sombra
        }
        
        plant.changeLight(to: nextValue)
        try? modelContext.save()
    }
    
    private func advanceStage() {
        plant.updateStageIfNeeded()
        try? modelContext.save()
    }
    
    private func deletePlant() {
        modelContext.delete(plant)
        dismiss()
    }
    
    // MARK: - Descripciones amigables
    
    private func waterDescription(_ value: Int) -> String {
        switch value {
        case ..<20:      return "Muy seco"
        case 20..<40:    return "Seco"
        case 40..<70:    return "Adecuado"
        case 70..<90:    return "Muy húmedo"
        default:         return "Exceso de agua"
        }
    }
    
    private func lightDescription(_ value: Int) -> String {
        switch value {
        case ..<20:      return "Sombra profunda"
        case 20..<40:    return "Sombra"
        case 40..<70:    return "Sombra parcial"
        case 70..<90:    return "Sol"
        default:         return "Sol intenso"
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CoffeePlant.self, configurations: config)
    
    let context = container.mainContext
    let samplePlant = CoffeePlant(
        name: "Cafeto de prueba",
        varietal: "Bourbon",
        createdAt: .now,
        stage: .seed,
        stageStartedAt: Date().addingTimeInterval(-3600),
        water: 65,
        light: 30,
        lastWaterUpdate: Date().addingTimeInterval(-2 * 3600),
        lastLightUpdate: Date().addingTimeInterval(-3 * 3600)
    )
    context.insert(samplePlant)
    
    return CoffeePlantDetailView(plant: samplePlant)
        .modelContainer(container)
}

