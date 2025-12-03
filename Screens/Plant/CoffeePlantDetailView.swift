import SwiftUI
import SwiftData

struct CoffeePlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var plant: CoffeePlant
    
    @State private var showDeleteAlert = false
    @State private var showRenameSheet = false
    @State private var newName: String = ""
    @State private var showTips = false
    @State private var showNutrientSheet = false
    @State private var nutrientFeedback: String?
    @State private var showWaterFX = false
    @State private var showHarvestFX = false
    @State private var bounceScale: CGFloat = 1.0
    @State private var cherries: [FlyingCherry] = []
    @State private var harvestTapCount = 0
    @State private var showBenefitSheet = false
    
    var isBouncing: Bool {
        showWaterFX || showHarvestFX
    }
    
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
                plantCard
                    .animation(.easeInOut(duration: 0.4), value: plant.light)
                    .padding(.horizontal, 20)
                
                actionsSection
                nutrientFeedbackSection
                advanceButton
                
                Spacer()
            }
        }
        .background(Color.ka_bg.ignoresSafeArea())
        .onAppear {
            nutrientFeedback = nil
            try? modelContext.save()
        }
        .toolbar { toolbarMenu }
        .alert("Consejos para \(plant.stage.displayName)",
               isPresented: $showTips) {
            Button("Cerrar", role: .cancel) {}
        } message: {
            Text(StageTips.tip(for: plant.stage, varietal: plant.varietalType))
        }
        .alert("¿Eliminar planta?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                deletePlant()
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $showBenefitSheet) {
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)
                
                Text("Elige el tipo de beneficio")
                    .font(.headline)
                    .padding(.top, 4)
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ka_surface)
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 4) {
                            Text(plant.name)
                                .font(.subheadline).bold()
                            Text("Varietal: \(plant.varietal)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Fase: Cosecha")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    )
                    .padding(.horizontal, 20)
                
                // Botones de tipo de beneficio
                HStack(spacing: 12) {
                    benefitOptionButton(
                        title: "Honey",
                        subtitle: "Más dulzor",
                        color: Color.orange.opacity(0.15)
                    ) {
                        selectBenefit(.honey)
                    }
                    
                    benefitOptionButton(
                        title: "Lavado",
                        subtitle: "Más claridad",
                        color: Color.blue.opacity(0.15)
                    ) {
                        selectBenefit(.washed)
                    }
                    
                    benefitOptionButton(
                        title: "Natural",
                        subtitle: "Frutal intenso",
                        color: Color.pink.opacity(0.15)
                    ) {
                        selectBenefit(.natural)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                Spacer(minLength: 0)
            }
            .presentationDetents([.fraction(0.45)])
            .presentationDragIndicator(.visible)
            .background(Color.ka_bg.ignoresSafeArea())
        }

        .sheet(isPresented: $showRenameSheet) { renameSheet }
        .confirmationDialog(
            "Elige un paquete de nutrientes",
            isPresented: $showNutrientSheet
        ) {
            Button("Paquete chico")  { applyNutrientPackage(.small) }
            Button("Paquete mediano"){ applyNutrientPackage(.medium) }
            Button("Paquete grande") { applyNutrientPackage(.large) }
            Button("Cancelar", role: .cancel) {}
        }
    }
}

private extension CoffeePlantDetailView {
    var plantCard: some View {
        Card {
            ZStack(alignment: .topTrailing) {
                lightBackgroundColor(for: plant.light)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(spacing: 16) {
                    Spacer().frame(height: 10)
                    
                    ZStack {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.93, green: 0.86, blue: 0.74))
                                .overlay(
                                    Circle()
                                        .stroke(Color.ka_coffee, lineWidth: 4)
                                )
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(Color.ka_coffee)
                                )
                                .scaleEffect(bounceScale)
                                

                            Image(systemName: "drop.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.ka_coffee)
                                .offset(y: -95)
                                .opacity(showWaterFX ? 1 : 0)
                                .animation(.easeOut(duration: 0.25),
                                           value: showWaterFX)
                        }
                        
                        ForEach(cherries) { cherry in
                            Image("Cherry")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .scaleEffect(cherry.scale)
                                .rotationEffect(.degrees(cherry.rotation))
                                .offset(x: cherry.x, y: cherry.y)
                                .opacity(cherry.opacity)
                        }
                       
                    }
                    .frame(width: 140, height: 140)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        handlePlantTap()
                        triggerBounce()
                    }
                    
                    Text(plant.stage.displayName)
                        .font(.headline)
                        
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tiempo en la etapa")
                            .font(.subheadline)
                        Text(plant.stageTime)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    
                    // Indicador si cumple requisitos
                    if plant.environmentRequirementsMet {
                        Text("✅ La planta está saludable")
                            .font(.footnote)
                            .foregroundStyle(.green)
                    } else {
                        Text("⚠️ Algo anda mal...")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    
                    // Calificación final de taza
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
                
                // Botón (i)
                Button {
                    showTips = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.ka_coffee)
                        .padding(8)
                }
            }
        }
    }
}

private extension CoffeePlantDetailView {
    var actionsSection: some View {
        Group {
            if plant.stage == .harvest {
                VStack(spacing: 10) {
                    if harvestTapCount < 5 {
                        Text("Presiona la planta para cosechar (\(harvestTapCount)/5)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("¡Cosecha lista! Ahora elige el tipo de beneficio.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 4)
                        
                        Button {
                            showBenefitSheet = true
                        } label: {
                            Label("Elegir tipo de beneficio", systemImage: "arrow.right.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.ka_coffee)
                                .foregroundStyle(Color.ka_surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else {
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
                    
                    // Fila 3: nutrientes (solo si aplica)
                    if shouldShowNutrientsButton {
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
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    var nutrientFeedbackSection: some View {
        Group {
            if let feedback = nutrientFeedback {
                Text(feedback)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    var advanceButton: some View {
        Group {
            if plant.stage != .harvest {
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
            }
        }
    }
}

private extension CoffeePlantDetailView {
    var toolbarMenu: some ToolbarContent {
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
    
    var renameSheet: some View {
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

private extension CoffeePlantDetailView {
    private func water() {
        plant.waterPlant(amount: 10)
        try? modelContext.save()
        
        showWaterFX = true
        triggerBounce()
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
        case ..<50:
            nextValue = 66   // sombra parcial
        case 50..<80:
            nextValue = 100   // sol fuerte
        default:
            nextValue = 33   // sombra
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
    
    private func benefitOptionButton(
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        BenefitOptionButton(title: title, subtitle: subtitle, color: color, action: action)
    }
    
    private func selectBenefit(_ type: BenefitProcess) {
        plant.benefitProcess = type
        plant.stage = .processing
        plant.stageStartedAt = Date()
        harvestTapCount = 0
        showBenefitSheet = false
        try? modelContext.save()
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
    
    private func handlePlantTap() {
        guard plant.stage == .harvest else { return }
        harvestTapCount += 1
        
        showHarvestFX = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            showHarvestFX = false
        }
        
        spawnCherry()
        
        try? modelContext.save()
    }
    
    func lightBackgroundColor(for light: Int) -> Color {
        switch light {
        case ..<50:
            return Color(red: 0.83, green: 0.78, blue: 0.72) // sombra
        case 50..<80:
            return Color(red: 0.90, green: 0.85, blue: 0.78) // sombra parcial
        default:
            return Color(red: 0.97, green: 0.92, blue: 0.80) // sol directo
        }
    }
    
    private func triggerBounce() {
        withAnimation(.timingCurve(0.15, 1.3, 0.4, 1.0, duration: 0.18)) {
            bounceScale = 1.18
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.58)) {
                bounceScale = 1.0
                showWaterFX = false
            }
        }
    }
    
    private func spawnCherry() {
        var cherry = FlyingCherry()
        cherry.x = 0
        cherry.y = 0
        cherry.scale = 0.6
        cherry.opacity = 1.0
        cherry.rotation = 0
        
        let id = cherry.id
        cherries.append(cherry)

        let distance = CGFloat(350)
        let angle = Double.random(in: 0...(2 * .pi))
        
        let targetX = CGFloat(cos(angle)) * distance
        let targetY = CGFloat(sin(angle)) * distance
        
    
        if let index = cherries.firstIndex(where: { $0.id == id }) {
            withAnimation(.easeOut(duration: 1.2)) {
                cherries[index].x = targetX
                cherries[index].y = targetY
                cherries[index].scale = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            cherries.removeAll { $0.id == id }
        }
    }


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

private struct FlyingCherry: Identifiable {
    let id = UUID()
    var x: CGFloat = 0
    var y: CGFloat = 0
    var scale: CGFloat = 0.6
    var opacity: Double = 1.0
    var rotation: Double = 0
}

private struct BenefitOptionButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.ka_coffee.opacity(0.25), lineWidth: 1)
            )
        }
    }
}
