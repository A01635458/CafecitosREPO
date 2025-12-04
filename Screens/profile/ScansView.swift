import SwiftUI

struct ScansView: View {

    @StateObject private var viewModel = ScansViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ka_bg.ignoresSafeArea()

                Group {
                    if viewModel.isLoading {
                        ProgressView("Cargando escaneos…")
                            .tint(Color.ka_coffee)
                    }

                    else if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Card {
                                VStack(spacing: 16) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(Color.ka_warnText)
                                            .font(.system(size: 26))

                                        Text("Ocurrió un error")
                                            .foregroundColor(Color.ka_warnText)
                                            .font(.headline)
                                    }

                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.black.opacity(0.7))
                                        .multilineTextAlignment(.center)

                                    Button(action: {
                                        Task { await viewModel.fetchScans() }
                                    }) {
                                        Text("Reintentar")
                                            .font(.body.weight(.medium))
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.ka_coffee)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 40)
                    }

                    else if viewModel.scans.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))

                            Text("No ha hecho ningún escaneo todavía")
                                .font(.title3)
                                .foregroundColor(Color.ka_coffee)
                        }
                        .padding(.top, 40)
                    }

                    else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.scans) { scan in
                                    NavigationLink(destination: ScanDetailView(scan: scan)) {
                                        ScanRow(scan: scan)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                .navigationTitle("Mis Escaneos")
                .toolbar {
                    Button(action: { Task { await viewModel.fetchScans() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.ka_coffee)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchScans()
        }
    }
}

#Preview {
    ScansView()
}
