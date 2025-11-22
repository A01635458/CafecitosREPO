//
//  AppView.swift
//  KaapehApp
//
//  Created by Alumnos on 20/11/25.
//
import Foundation
import SwiftUI
import Supabase

struct AppView: View {
    @StateObject private var authViewModel = AuthViewModel()
  var body: some View {
    Group {
        if authViewModel.isAuthenticated {
        RootTabView(authViewModel: authViewModel)
      } else {
          AuthView(authViewModel: authViewModel)
      }
    }
    .task {
        await authViewModel.getInitialSession()
        }
      }
    }
  
