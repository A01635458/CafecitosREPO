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
            
            CameraView()
                .tabItem { Label("Cámara", systemImage: "camera.fill") }
                .tag(0)
  
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Inicio", systemImage: "house.fill") }
                .tag(1)

            LearnView()
                .tabItem { Label("Aprender", systemImage: "book.fill") }
                .tag(2)
            
            CoffeePlantListView()
                .tabItem { Label("Plantas", systemImage: "leaf.fill") }
                .tag(3)
                
            ProfileView(authViewModel: authViewModel)
                .tabItem { Label("Perfil", systemImage: "person.circle.fill") }
                .tag(4)
        }
        .tint(.ka_coffee)
        .background(Color.ka_surface)
    }
}


