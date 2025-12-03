import SwiftUI
import SwiftData
import Supabase



// MARK: - Lista de plantas

struct CoffeePlantListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeePlant.createdAt, order: .forward) private var plants: [CoffeePlant]
    
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var isPresentingAdd = false
    
    // Estados de sync
    @State private var isUploading = false
    @State private var isDownloading = false
    @State private var syncErrorMessage: String?
    
    @State private var showUploadConfirm = false
    @State private var showDownloadConfirm = false
    
    private var isBusy: Bool { isUploading || isDownloading }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Text("Mis plantas")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    // Botón descargar ⬇️
                    Button {
                        showDownloadConfirm = true
                    } label: {
                        if isDownloading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    .disabled(isBusy)
                    .tint(Color.ka_coffee)
                    .accessibilityLabel("Descargar plantas desde la nube")
                    
                    // Botón subir ⬆️
                    Button {
                        showUploadConfirm = true
                    } label: {
                        if isUploading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 20, weight: .semibold))
                        }
                    }
                    .disabled(isBusy)
                    .tint(Color.ka_coffee)
                    .accessibilityLabel("Subir plantas a la nube")
                    
                    // Botón agregar planta
                    Button {
                        isPresentingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color.ka_coffee)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                .background(Color.ka_surface)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color.ka_divider),
                    alignment: .bottom
                )
                
                // Lista
                ScrollView {
                    VStack(spacing: 16) {
                        if plants.isEmpty {
                            VStack(spacing: 12) {
                                Text("Aún no has registrado ninguna planta ☕️🌱")
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                Button {
                                    isPresentingAdd = true
                                } label: {
                                    Text("Registrar mi primera planta")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.ka_coffee)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 24)
                        } else {
                            ForEach(plants) { plant in
                                NavigationLink {
                                    CoffeePlantDetailView(plant: plant)
                                } label: {
                                    CoffeePlantCard(plant: plant)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                    }
                }
                .background(Color.ka_bg)
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddCoffeePlantView()
        }
        // Alert de error
        .alert("Error al sincronizar",
               isPresented: Binding(
                get: { syncErrorMessage != nil },
                set: { _ in syncErrorMessage = nil }
               )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(syncErrorMessage ?? "Ocurrió un error desconocido.")
        }
        // Confirm subir
        .confirmationDialog(
            "Subir plantas a la nube",
            isPresented: $showUploadConfirm
        ) {
            Button("Subir ahora", role: .destructive) {
                Task { await uploadPlants() }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Se enviarán todas tus plantas locales a Supabase.")
        }
        // Confirm descargar
        .confirmationDialog(
            "Descargar plantas desde la nube",
            isPresented: $showDownloadConfirm
        ) {
            Button("Descargar ahora") {
                Task { await downloadPlants() }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Se sincronizarán las plantas guardadas en Supabase con tu dispositivo.")
        }
    }
}

extension CoffeePlantListView {
    
    @MainActor
    private func uploadPlants() async {
        isUploading = true
        defer { isUploading = false }
        
        do {
            let session = try await supabase.auth.session
            let currentUser = session.user
            
            let remotesToUpload = plants.map { $0.toRemote(userId: currentUser.id) }
            
            _ = try await supabase
                .from("coffee_plants")
                .upsert(remotesToUpload)
                .execute()
            
        } catch {
            syncErrorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func downloadPlants() async {
        isDownloading = true
        defer { isDownloading = false }
        
        do {
            let session = try await supabase.auth.session
            let currentUser = session.user
            
            let response: PostgrestResponse<[RemoteCoffeePlant]> = try await supabase
                .from("coffee_plants")
                .select("*")    
                .eq("user_id", value: currentUser.id)
                .order("created_at", ascending: true)
                .execute()
            
            let remotePlants = response.value
            applyRemotePlants(remotePlants)
            try modelContext.save()
            
        } catch {
            syncErrorMessage = error.localizedDescription
        }
    }
    
    /// Fusiona plantas remotas con las locales (update/insert)
    @MainActor
    private func applyRemotePlants(_ remotePlants: [RemoteCoffeePlant]) {
        for remote in remotePlants {
            if let existing = plants.first(where: { $0.id == remote.id }) {
                existing.name = remote.name
                existing.varietal = remote.varietal
                existing.stage = CoffeeStage(rawValue: remote.stage) ?? existing.stage
                existing.stageStartedAt = remote.stageStartedAt
            } else {
                let newPlant = remote.toLocal()
                modelContext.insert(newPlant)
            }
        }
    }
}
// MARK: - Card resumida para la lista

private struct CoffeePlantCard: View {
    let plant: CoffeePlant
    
    var body: some View {
        Card {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(red: 0.93, green: 0.86, blue: 0.74))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.ka_coffee)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(plant.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Text("\(plant.varietal) • \(plant.stage.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        Label("\(plant.water)%", systemImage: "drop.fill")
                            .font(.caption)
                        Label("\(plant.light)%", systemImage: "sun.max.fill")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
    }
}

// MARK: - Vista para agregar nueva planta

private struct AddCoffeePlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var selectedVarietal: CoffeeVarietal = .bourbon
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Registrar nueva planta")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                        
                        Text("Ponle un nombre a tu planta de café para comenzar a cuidarla.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        TextField("Nombre de la planta", text: $name)
                            .textFieldStyle(.plain)
                            .padding(10)
                            .background(Color.ka_bg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        // Picker de tipo de café
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de café")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Picker("Tipo de café", selection: $selectedVarietal) {
                                ForEach(CoffeeVarietal.allCases) { varietal in
                                    Text(varietal.rawValue)
                                        .tag(varietal)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Button {
                    createPlant()
                } label: {
                    Text("Crear planta")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
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
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createPlant() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let plant = CoffeePlant(
            name: trimmedName,
            varietal: selectedVarietal.rawValue, // 👈 guardas el tipo elegido
            // el resto usa defaults de tu init (stage, water, light, etc.)
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

