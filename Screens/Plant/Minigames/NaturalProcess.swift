import SwiftUI

struct NaturalProcessView: View {
    var onFinished: () -> Void
    
    private let canvasSize = CGSize(width: 320, height: 360)
    
    private struct NaturalCherry: Identifiable {
        enum Ripeness {
            case wet      // poco secado
            case ideal      // secado perfecto
            case dry       // sobresecado
        }
        
        let id = UUID()
        var position: CGPoint
        var ripeness: Ripeness
        var isSelected: Bool = false
    }
    
    @State private var cherries: [NaturalCherry] = []
    @State private var isCompleted: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Proceso Natural")
                .font(.title2.bold())
            
            Text("En el proceso natural, las cerezas se secan enteras al sol. Toca las cerezas con secado ideal.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.97, green: 0.93, blue: 0.86),
                                Color(red: 0.98, green: 0.95, blue: 0.90)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.ka_coffee.opacity(0.18), lineWidth: 1)
                    )
                
                ForEach(cherries.indices, id: \.self) { index in
                    let cherry = cherries[index]

                    Image(assetName(for: cherry))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .scaleEffect(cherry.isSelected ? 0.85 : 1.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    cherry.isSelected
                                    ? Color.ka_coffee.opacity(0.7)
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .position(cherry.position)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.7),
                            value: cherry.isSelected
                        )
                        
                        .onTapGesture {
                            handleTap(id: cherry.id)
                        }
                }

            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .padding(.horizontal, 24)
            .onAppear {
                generateCherries()
            }
            
            if isCompleted {
                Text("¡Secado natural listo!")
                    .font(.headline)
                
                Button {
                    onFinished()
                } label: {
                    Text("Continuar")
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.ka_coffee)
                        .foregroundStyle(Color.ka_surface)
                        .clipShape(Capsule())
                }
            } else {
                Text("Selecciona todas las cerezas con secado ideal.\nEvita las que están muy crudas o sobresecadas.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .padding()
        .background(Color.ka_bg.ignoresSafeArea())
    }
}

// MARK: - Lógica
private extension NaturalProcessView {
    
    func generateCherries() {
        let idealCount = 4
        let underCount = 3
        let overCount = 2
        
        var temp: [NaturalProcessView.NaturalCherry] = []
        
        func randomPosition(existing: [NaturalCherry]) -> CGPoint {
            let maxAttempts = 40
            var attempts = 0
            
            while attempts < maxAttempts {
                attempts += 1
                
                let p = CGPoint(
                    x: CGFloat.random(in: 50...(canvasSize.width - 50)),
                    y: CGFloat.random(in: 60...(canvasSize.height - 60))
                )
                
                let tooClose = existing.contains { other in
                    let d = hypot(p.x - other.position.x, p.y - other.position.y)
                    return d < 80
                }
                
                if !tooClose {
                    return p
                }
            }
            
            return CGPoint(
                x: CGFloat.random(in: 50...(canvasSize.width - 50)),
                y: CGFloat.random(in: 60...(canvasSize.height - 60))
            )
        }

        
        // Crear ideales
        for _ in 0..<idealCount {
            let pos = randomPosition(existing: temp)
            temp.append(NaturalCherry(position: pos, ripeness: .ideal))
        }
        
        // Crear under
        for _ in 0..<underCount {
            let pos = randomPosition(existing: temp)
            temp.append(NaturalCherry(position: pos, ripeness: .wet))
        }
        
        // Crear over
        for _ in 0..<overCount {
            let pos = randomPosition(existing: temp)
            temp.append(NaturalCherry(position: pos, ripeness: .dry))
        }
        
        cherries = temp.shuffled()
    }
    
  private func assetName(for cherry: NaturalCherry) -> String {
        switch cherry.ripeness {
        case .ideal:
            return "Cherry"
        case .wet:
            return "cherryWet"
        case .dry:
            return "cherryDry"
        }
    }

    
    func handleTap(id: UUID) {
        guard !isCompleted else { return }
        guard let index = cherries.firstIndex(where: { $0.id == id }) else { return }
        
        cherries[index].isSelected.toggle()
        checkCompletion()
    }
    
    func checkCompletion() {
        let allIdealSelected = cherries
            .filter { $0.ripeness == .ideal }
            .allSatisfy { $0.isSelected }
        
        let noWrongSelected = cherries
            .filter { $0.ripeness != .ideal }
            .allSatisfy { !$0.isSelected }
        
        if allIdealSelected && noWrongSelected {
            isCompleted = true
        }
    }
}

