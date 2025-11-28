import SwiftUI
import SwiftData

struct CoffeePlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var plant: CoffeePlant
    
    @State private var showDeleteAlert = false
    @State private var showRenameSheet = false
    @State private var newName: String = ""
    
    @State private var showNutrientSheet = false
    @State private var nutrientFeedback: String?
    
    private var shouldShowNutrientsButton: Bool {
        switch plant.stage {
        case
             .seed,
             .germination,
             .seedling,
             .juvenile,
             .transplanted,
             .vegetative,
             .flowering,
             .greenCherry,
             .ripeCherry:
            return true
        default:
            return false
        }
    }
    
    var body: some View {
        ScrollView {
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
                        
                        // Progreso de la etapa actual (si lo quieres dejar por ahora)
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
                        
                        // Indicador de si cumple requisitos
                        if plant.environmentRequirementsMet {
                            Text("✅ La planta está saludable")
                                .font(.footnote)
                                .foregroundStyle(.green)
                        } else {
                            Text("⚠️ Algo anda mal...")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }
                        
                        // Calificación de taza solo en etapa .cup
                        if plant.stage == .cup {
                            VStack(spacing: 4) {
                                Text("Calificación SCA: \(plant.finalCupScore)/100")
                                    .font(.headline)
                                Text(plant.finalCupGrade)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(16)
                }
            }
            .padding(.horizontal, 20)
            
            // Botones de acción principales
            VStack(spacing: 10) {
                // Fila 1: regar / quitar
                HStack(spacing: 12) {
                    Button {
                        removeWater()
                    } label: {
                        Label("Quitar Agua", systemImage: "drop.triangle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.ka_coffee)
                            .foregroundStyle(Color.ka_surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
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
                }
                
                // Fila 2: sombra / luz
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
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Fila 3: nutrientes
                Button {
                    showNutrientSheet = true
                } label: {
                    Label("Nutrientes", systemImage: "leaf.circle.fill")
                        .font(.system(size: 14, weight: .bold))
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
            }
            .padding(.horizontal, 20)

            .padding(.horizontal, 20)
            
            // Feedback de nutrientes (se limpia al avanzar de etapa)
            if let feedback = nutrientFeedback {
                Text(feedback)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Botón para intentar avanzar de estado
            Button {
                advanceStage()
            } label: {
                Label("Avanzar la fase", systemImage: "arrow.right.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.ka_coffee)
                    .foregroundStyle(Color.ka_surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ka_surface.opacity(0.25), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .onAppear {
            nutrientFeedback = nil
            try? modelContext.save()
        }
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
        .alert("¿Eliminar planta?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                deletePlant()
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
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
        
        .confirmationDialog(
            "Elige un paquete de nutrientes",
            isPresented: $showNutrientSheet
        ) {
            Button("Paquete chico") {
                applyNutrientPackage(.small)
            }
            Button("Paquete mediano") {
                applyNutrientPackage(.medium)
            }
            Button("Paquete grande") {
                applyNutrientPackage(.large)
            }
            Button("Cancelar", role: .cancel) {}
        }
    }
    
    // MARK: - Actions
    
    private func water() {
        plant.waterPlant(amount: 10)
        try? modelContext.save()
    }
    
    private func removeWater() {
        plant.water = max(0, plant.water - 10)
        plant.lastWaterUpdate = .now
        try? modelContext.save()
    }

    private func cycleLight() {
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
        nutrientFeedback = nil
        try? modelContext.save()
    }
    
    private func deletePlant() {
        modelContext.delete(plant)
        dismiss()
    }
    
    private func applyNutrientPackage(_ package: NutrientPackage) {
        let correct = plant.applyNutrients(package)
        try? modelContext.save()
        
        if correct {
            nutrientFeedback = "✅ Elegiste el paquete correcto para esta etapa."
        } else {
            nutrientFeedback = "⚠️ Este paquete no es ideal en esta etapa."
        }
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

