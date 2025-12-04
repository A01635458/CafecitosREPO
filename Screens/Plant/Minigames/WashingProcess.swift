import SwiftUI
import Combine

struct WashingProcessView: View {
    var onFinished: () -> Void
    
    private let canvasSize = CGSize(width: 320, height: 380)
    private let requiredWashTime: Double = 7.0
    
    struct Cherry: Identifiable {
        let id = UUID()
        var position: CGPoint
    }
    
    // MARK: - State
    @State private var cherries: [Cherry] = []
    @State private var showerPosition: CGPoint = CGPoint(x: 160, y: 80)
    @State private var washedTime: Double = 0.0
    @State private var isCompleted: Bool = false
    
    // Timer
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Beneficio Lavado")
                .font(.title2.bold())
            
            Text("Arrastra el chorro de agua sobre las cerezas para lavarlas.")
                .font(.callout)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ZStack {
                background
            
                ForEach(cherries) { cherry in
                    let progress = min(washedTime / requiredWashTime, 1.0)
                    let opacity = 0.35 + 0.65 * progress
                    
                    Image("Cherry")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .opacity(opacity)
                        .position(cherry.position)
                }
                
                // CHORRO DE AGUA
                shower
            }
            .frame(width: canvasSize.width, height: canvasSize.height)
            .onAppear {
                cherriesPos()
            }
            .onReceive(timer) { _ in
                washingProgressBar()
            }
            
            progressBar
            
            if isCompleted {
                nextButton
            }
        }
        .padding()
        .background(Color.ka_bg.ignoresSafeArea())
    }
}

private extension WashingProcessView {
    // MARK: - Canvas Background
    var background: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.12),
                        Color.cyan.opacity(0.24)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.ka_coffee.opacity(0.15), lineWidth: 1)
            )
    }
    
    var shower: some View {
        Image(systemName: "shower.sidejet")
            .font(.system(size: 40))
            .symbolRenderingMode(.hierarchical)
            .rotationEffect(.degrees(90))
            .position(showerPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let x = min(max(value.location.x, 20), canvasSize.width - 20)
                        let y = min(max(value.location.y, 20), canvasSize.height - 20)
                        showerPosition = CGPoint(x: x, y: y)
                    }
            )
    }
    
    var progressBar: some View {
        ProgressView(value: washedTime, total: requiredWashTime) {
            Text("Lavando…")
        } currentValueLabel: {
            Text("\(Int(washedTime))s / \(Int(requiredWashTime))s")
                .font(.caption)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Next Button
    var nextButton: some View {
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

private extension WashingProcessView {
    // MARK: - Generate Random Positions
    func cherriesPos() {
        var generated: [Cherry] = []
        
        for _ in 0..<5 {
            var position: CGPoint
            
            repeat {
                position = CGPoint(
                    x: CGFloat.random(in: 50...270),
                    y: CGFloat.random(in: 130...340)
                )
            } while generated.contains(where: { existing in
                let dist = hypot(position.x - existing.position.x,
                                 position.y - existing.position.y)
                return dist < 70  // evita superposición
            })
            
            generated.append(Cherry(position: position))
        }
        
        cherries = generated
    }
    
    // MARK: - Washing logic
    func washingProgressBar() {
        guard !isCompleted else { return }
        
        let isOverAny = cherries.contains { cherry in
            let distance = hypot(
                showerPosition.x - cherry.position.x,
                showerPosition.y - cherry.position.y
            )
            return distance < 65
        }
        
        if isOverAny {
            washedTime = min(requiredWashTime, washedTime + 0.1)
            if washedTime >= requiredWashTime {
                isCompleted = true
            }
        }
    }
}

