import SwiftUI
import Combine


struct HoneyProcessView: View {
    var onFinished: () -> Void
    
    // Nivel de miel
    @State private var currentLevel: Double = 0
    
    // Tiempo acumulado en zona ideal
    @State private var stableTime: Double = 0.0
    
    @State private var isCompleted: Bool = false
    @State private var isPressing: Bool = false
    
    // Configuración
    private let targetMin: Double = 40
    private let targetMax: Double = 60
    private let requiredStableTime: Double = 6.0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Beneficio Honey")
                .font(.title2.bold())
            
            Text("Mantén presionado para aumentar el nivel de Honey.\nQuédate en la zona ideal para completar el proceso.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.08),
                                Color.yellow.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.ka_coffee.opacity(0.15), lineWidth: 1)
                    )
                
                HStack(spacing: 32) {
                    levelBar
                    levelInfo
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .frame(height: 300)
            .padding(.horizontal, 24)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressing = true }
                    .onEnded { _ in isPressing = false }
            )
            .onReceive(timer) { _ in updateLogic() }
            
            ProgressView(value: stableTime, total: requiredStableTime) {
                Text("Controlando el honey…")
            } currentValueLabel: {
                Text("\(stableTime, specifier: "%.1f")s / \(requiredStableTime, specifier: "%.1f")s")
                    .font(.caption)
            }
            .padding(.horizontal)
            
            if isCompleted {
                Text("¡Honey listo!")
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
            }
        }
        .padding()
        .background(Color.ka_bg.ignoresSafeArea())
    }
}


// MARK: - Barra e indicadores
private extension HoneyProcessView {
    
    var levelBar: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let barWidth: CGFloat = 36
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.ka_surface)
                
                Rectangle()
                    .fill(Color.green.opacity(0.35))
                    .frame(height: ((targetMax - targetMin) / 100) * height)
                    .offset(y: idealOffset(in: height))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Circle()
                    .fill(Color.orange)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(Color.ka_coffee.opacity(0.4), lineWidth: 2)
                    )
                    .offset(y: indicatorOffset(in: height))
                    .shadow(radius: 2, y: 1)
            }
            .frame(width: barWidth)
        }
        .frame(width: 36)
    }
    
    var levelInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nivel de Honey")
                .font(.subheadline.bold())
            
            Text("\(Int(currentLevel)) / 100")
                .font(.title3.monospacedDigit())
            
            Spacer()
        }
    }
    
    func indicatorOffset(in height: CGFloat) -> CGFloat {
        let normalized = currentLevel / 100
        return (0.5 - normalized) * height
    }
    
    func idealOffset(in height: CGFloat) -> CGFloat {
        let mid = (targetMin + targetMax) / 2
        let normalized = mid / 100
        return (0.5 - normalized) * height
    }
}


private extension HoneyProcessView {
    
    func updateLogic() {
        guard !isCompleted else { return }
        
        
        if isPressing {
            currentLevel = min(100, currentLevel + 1.8)
        } else {
            currentLevel = max(0, currentLevel - 1.0)
            
            if currentLevel >= targetMin && currentLevel <= targetMax {
                stableTime = min(requiredStableTime, stableTime + 0.1)
            } else {
            }
            
            if stableTime >= requiredStableTime {
                isCompleted = true
            }
        }
    }
}
