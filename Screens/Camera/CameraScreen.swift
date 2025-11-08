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
    @Published var detectedLabel: String? // ← etiqueta detectada del modelo
    
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var model: VNCoreMLModel?

    override init() {
        super.init()
        configure()
        loadModel()
    }

    private func loadModel() {
        // Carga del modelo GatosyPerros.ml
        guard let mlModel = try? GatosyPerros(configuration: MLModelConfiguration()).model,
              let vnModel = try? VNCoreMLModel(for: mlModel) else {
            print("⚠️ No se pudo cargar el modelo GatosyPerros.ml")
            return
        }
        self.model = vnModel
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(output)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
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
                        // TODO: flip camera
                    } label: {
                        Circle().fill(Color.black.opacity(0.5))
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "camera.rotate").foregroundStyle(.white))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                Text("Enfoca un gato o un perro 🐾")
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
                VStack(spacing: 16) {
                    Text(popupTitle)
                        .font(.system(size: 22, weight: .bold))
                    Text(popupText)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                    Button("Cerrar") {
                        withAnimation { showPopup = false }
                    }
                    .padding(.top, 10)
                }
                .padding(30)
                .frame(maxWidth: 300)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .transition(.scale)
            }
        }
        .onChange(of: camera.detectedLabel) { _, newLabel in
            guard let label = newLabel else { return }
            switch label {
            case "dog":
                popupTitle = "🐶 Perro detectado"
                popupText = "Los perros son animales leales y sociales. En este ejemplo, podrías mostrar información educativa sobre su rol en la caficultura o su entorno."
                withAnimation { showPopup = true }
            case "cat":
                popupTitle = "🐱 Gato detectado"
                popupText = "Los gatos son animales observadores y ágiles. En el contexto de Káapeh, podrías mostrar datos curiosos o su relación con las fincas de café."
                withAnimation { showPopup = true }
            default:
                break
            }
        }
    }
}
