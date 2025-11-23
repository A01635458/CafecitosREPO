//
//  CameraScreen.swift
//  KaapehApp
//

import SwiftUI
import AVFoundation
import Combine
import Vision
import CoreML

final class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isRunning = false
    @Published var lastImage: UIImage?
    @Published var detectedLabel: String?
    @Published var currentPosition: AVCaptureDevice.Position = .back
    
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var model: VNCoreMLModel?

    override init() {
        super.init()
        configure(position: currentPosition)
        loadModel()
    }

    private func loadModel() {
        guard let mlModel = try? GranosClassifier(configuration: MLModelConfiguration()).model,
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            print("⚠️ No se pudo cargar el modelo GranosClassifier.ml")
            return
        }
        self.model = vnModel
    }

    private func configure(position: AVCaptureDevice.Position) {
        session.beginConfiguration()
        
        for input in session.inputs {
            session.removeInput(input)
        }
        
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            print("⚠️ No se pudo configurar la cámara \(position)")
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        
        if !session.outputs.contains(where: { $0 === output }) {
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }
        
        session.commitConfiguration()
    }
    
    func flipCamera() {
        currentPosition = (currentPosition == .back) ? .front : .back
        session.stopRunning()

        DispatchQueue.global(qos: .userInitiated).async {
            self.configure(position: self.currentPosition)
            
            usleep(30000)

            self.session.startRunning()
        }
    }

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { self.session.startRunning() }
        isRunning = true
    }

    func stop() {
        guard session.isRunning else { return }
        session.stopRunning()
        isRunning = false
    }

    func capture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let img = UIImage(data: data) else { return }

        DispatchQueue.main.async { self.lastImage = img }
        analyze(image: img)
    }

    private func analyze(image: UIImage) {
        guard let cgImage = image.cgImage, let model = model else { return }

        let request = VNCoreMLRequest(model: model) { req, _ in
            guard let result = req.results?.first as? VNClassificationObservation else { return }
            DispatchQueue.main.async {
                self.detectedLabel = result.identifier.lowercased()
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = UIScreen.main.bounds
        view.layer.addSublayer(layer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraModel()
    @State private var showPopup = false
    @State private var popupTitle = ""
    @State private var popupText = ""
    @State private var specialtyImpact = ""
    @State private var preventionTips = ""

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
                .onAppear { camera.start() }
                .onDisappear { camera.stop() }

            VStack {
                // top bar
                HStack {
                    Button { dismiss() } label: {
                        Circle().fill(Color.black.opacity(0.5))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "xmark").foregroundStyle(.white))
                    }
                    Spacer()
                    Button {
                        camera.flipCamera()
                    } label: {
                        Circle().fill(Color.black.opacity(0.5))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "camera.rotate").foregroundStyle(.white))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                Text("Enfoca un grano de cafe 🫘")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .shadow(radius: 4)
                    .padding(.bottom, 20)

                Button { camera.capture() } label: {
                    ZStack {
                        Circle().stroke(.white.opacity(0.5), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        Circle().fill(Color.ka_coffee)
                            .frame(width: 64, height: 64)
                    }
                }
                .padding(.bottom, 40)
            }

            // Popup de resultado
            if showPopup {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(popupTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.black)
                        Text(popupText)
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.black)
                        
                        if !specialtyImpact.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("🌟 El grano aporta al café de especialidad? ")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)

                                Text(specialtyImpact)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        if !preventionTips.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("🛠 Cómo prevenir este defecto")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)

                                Text(preventionTips)
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        Button("Cerrar") {
                            withAnimation { showPopup = false }
                        }
                        .padding(.top, 10)
                    }
                    .padding(30)
                }
                .frame(maxWidth: 300)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .transition(.scale)
            }
        }
        .onChange(of: camera.detectedLabel) { _, newLabel in
            guard let label = newLabel else { return }
            
            specialtyImpact = ""
            preventionTips = ""
            
            switch label {
            case "agrio":
                popupTitle = "🍋 Grano Agrio"
                popupText = "Los granos agrios provienen usualmente de frutos sobremaduros o fermentados antes del despulpado. Esto puede ocurrir cuando las cerezas permanecen demasiado tiempo en el suelo o en el árbol después de madurar. Estos granos generan sabores a vinagre, limón intenso o fermentación indeseada, afectando gravemente el perfil de taza. Su identificación y separación es crucial para mantener la calidad del café."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos generan sabores agresivos, altamente fermentados y no controlables. En los estándares SCA, el grano agrio se clasifica como un defecto primario y reduce drásticamente el puntaje de taza."
                preventionTips = "Cosechar únicamente cerezas maduras, evitar que el fruto permanezca en el suelo, controlar la fermentación y despulpar en un máximo de 6–8 horas después de cosechar."
                withAnimation { showPopup = true }
            case "cereza seca":
                popupTitle = "🌰 Cereza Seca"
                popupText = "Las cerezas secas son frutos que se deshidrataron sin ser recolectados o sin pasar por el proceso de despulpado. Esto puede suceder por recolección tardía o mal manejo en la finca. Son extremadamente duras y no permiten una separación adecuada durante la trilla. En la taza generan sabores terrosos, a madera seca o astringentes."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos afectan la uniformidad del lote e introduce sabores a madera seca o tierra, reduciendo claridad y dulzor. En café de especialidad afecta el puntaje final porque altera el perfil limpio y consistente requerido por SCA."
                preventionTips = "Recolectar de manera más frecuente, revisar el piso de recolección, y mejorar las prácticas de clasificación manual para retirar frutos secos antes del despulpado."
                withAnimation { showPopup = true }
            case "conchas":
                popupTitle = "🟤 Grano Concha"
                popupText = "Los granos concha se caracterizan por ser huecos, muy livianos y con forma irregular. Se producen cuando la semilla no se desarrolla completamente por falta de nutrientes, estrés hídrico o defectos genéticos. Durante el tostado tienden a quemarse más rápido, provocando notas amargas o sabores a quemado. Son considerados un defecto serio en la clasificación."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos, durante el tostado se queman más rápido, generando amargor. Esto afecta la uniformidad y reduce el puntaje de consistencia en catación, clave para café de especialidad."
                preventionTips = "Evitar estrés hídrico, mejorar fertilización balanceada y verificar condiciones de sombra y salud del cafeto."
                withAnimation { showPopup = true }
            case "esponjoso":
                popupTitle = "☁️ Grano Esponjoso"
                popupText = "El grano esponjoso presenta una textura ligera y poco densa debido a una mala deshidratación o secado demasiado rápido. Estos granos absorben el calor de manera irregular durante el tostado y producen sabores planos, falta de cuerpo y una extracción dispareja en la preparación final."
                specialtyImpact = " ⚠️ Este grano de cafe, solo aporta un poco a la elaboracion de cafe de especialidad, ya que estos granos comprometen directamente la estructura del tueste y la extracción. En café de especialidad generan pérdida de cuerpo y afectan el balance general, bajando el puntaje final."
                preventionTips = "Controlar el secado, evitar temperaturas altas, asegurar un proceso más lento y uniforme."
                withAnimation { showPopup = true }
            case "fogueado":
                popupTitle = "🔥 Grano Fogueado"
                popupText = "El grano fogueado es el resultado de un secado excesivo o exposición directa a temperaturas muy altas, comúnmente cuando se extiende el café bajo el sol intenso sin protección. Este daño provoca un aspecto quemado o tostado prematuro, generando sabores ahumados, a madera quemada o amargor indeseado."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos generan sabores ahumados y quemados que eliminan cualquier posibilidad de un perfil limpio, requisito esencial para café de especialidad."
                preventionTips = "Secar bajo sombra, rotar el café constantemente, evitar exposición directa al sol intenso."
                withAnimation { showPopup = true }
            case "veteado":
                popupTitle = "⚡ Grano Veteado"
                popupText = "Los granos veteados presentan líneas internas o variaciones de color que indican problemas en su formación, como deficiencias nutricionales, estrés por sombra excesiva o enfermedades durante el desarrollo del fruto. Los granos veteados presentan líneas internas o variaciones de color que indican problemas en su formación, como deficiencias nutricionales, estrés por sombra excesiva o enfermedades durante el desarrollo del fruto."
                specialtyImpact = " ⚠️ Este grano de cafe, solo aporta un poco a la elaboracion de cafe de especialidad, ya que estos granos afectan la consistencia del lote y puede generar sabores herbales o desequilibrados. No siempre es un defecto severo, pero reduce la uniformidad requerida para puntajes altos."
                preventionTips = "Mejorar nutrición del árbol, controlar enfermedades y garantizar desarrollo uniforme del fruto."
                withAnimation { showPopup = true }
            case "cafeblanco":
                popupTitle = "⚪ Café Blanco"
                popupText = "El café blanco tiene un color muy claro debido a un despulpado incompleto o falta de desarrollo del mucílago. También puede ser un indicador de inmadurez interna del grano. En taza produce sabores apagados, muy bajos en dulzor y con acidez punzante. Su presencia suele indicar fallas en el beneficio húmedo."
                specialtyImpact = " ⚠️ Este grano de cafe, solo aporta un poco a la elaboracion de cafe de especialidad, ya que estos granos producen una taza apagada, sin dulzor. Esto afecta directamente atributos evaluados por SCA como dulzor, acidez balanceada y limpieza del sabor."
                preventionTips = "Revisar calibración de despulpadora, mejorar calidad del beneficio húmedo."
                withAnimation { showPopup = true }
            case "cafeinmaduro":
                popupTitle = "🟢 Café Inmaduro"
                popupText = "Los granos inmaduros provienen de frutos verdes cosechados antes de tiempo. Estos granos tienen baja concentración de azúcares y compuestos aromáticos. En la taza aportan sabores vegetales, amargos y una acidez muy marcada y poco agradable. Su separación es esencial para evitar perfiles de taza defectuosos."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos reducen fuertemente el puntaje por amargor, astringencia y acidez desagradable. La recolección selectiva es indispensable para café de especialidad."
                preventionTips = "Recolección por puntos maduros, capacitación en selección de cerezas."
                withAnimation { showPopup = true }
            case "cafenegro":
                popupTitle = "⚫ Café Negro"
                popupText = "El café negro suele ser resultado de fermentación avanzada, daño por humedad, enfermedades o mal almacenamiento. Estos granos absorben sabores indeseados del entorno, presentan riesgo microbiológico y son uno de los defectos más críticos en la clasificación. Aportan sabores a moho, tierra húmeda o fermento excesivo."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos pueden arruinar lotes completos. Introduce sabores a moho y tierra húmeda: causa rechazo automático en estándares de café de especialidad."
                preventionTips = "Controlar humedad, evitar almacenamiento húmedo, mejorar proceso de secado y selección post-proceso."
                withAnimation { showPopup = true }
            case "cafepergamino":
                popupTitle = "📜 Café en Pergamino"
                popupText = "El café pergamino conserva la capa protectora que envuelve al grano. Si aparece en la clasificación final es señal de un trillado deficiente o de una calibración incorrecta de las máquinas. Aunque no siempre implica un defecto del grano, sí afecta la consistencia del proceso de beneficio seco y debe removerse para mantener la uniformidad."
                specialtyImpact = " ⚠️ Este grano de cafe, solo aporta un poco a la elaboracion de cafe de especialidad, ya que estos granos no siempre afectan la taza, pero sí afectan la uniformidad del proceso, lo cual impacta la consistencia del lote."
                preventionTips = "Mejor calibración de trilladora, revisión manual durante el beneficio seco."
                withAnimation { showPopup = true }
            case "dañoporhongo":
                popupTitle = "🍄 Grano Dañado por Hongo"
                popupText = "Los granos dañados por hongo presentan manchas, coloración irregular, textura quebradiza o puntos oscuros característicos. Son consecuencia de exceso de humedad en la fermentación, almacenamiento inadecuado o lluvias durante el secado. Estos granos afectan la inocuidad del producto y generan sabores a moho, tierra mojada o fermentación indeseada. Deben ser eliminados completamente."
                specialtyImpact = " ❌ Este grano de cafe no aporta a la elaboracion de cafe de especialidad, ya que estos granos afectan inocuidad del producto y destruye el perfil de taza. Los estándares SCA penalizan fuertemente este defecto."
                preventionTips = "Controlar humedad, evitar lluvias durante secado."
                withAnimation { showPopup = true }
            default:
                break
            }
        }
    }
}
