//
//  RootTabView.swift
//  KaapehApp
//

import SwiftUI

struct RootTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 1

    var body: some View {
        TabView(selection: $selectedTab) {

            Tab("Cámara", systemImage: "camera.fill", value: 0) {
                CameraView()
            }

            Tab("Inicio", systemImage: "house.fill", value: 1) {
                HomeView(selectedTab: $selectedTab)
            }

            Tab("Aprender", systemImage: "book.fill", value: 2) {
                LearnView()
            }

            Tab("Plantas", systemImage: "leaf.fill", value: 3) {
                CoffeePlantListView(authViewModel: authViewModel)
            }

            Tab("Perfil", systemImage: "person.circle.fill", value: 4) {
                ProfileView(authViewModel: authViewModel)
            }
        }
        .tint(.ka_coffee)
        .background(Color.ka_surface)
    }
}

