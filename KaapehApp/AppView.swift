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
  @State var isAuthenticated = false
  var body: some View {
    Group {
      if isAuthenticated {
        RootTabView()
      } else {
        AuthView()
      }
    }
    .task {
      for await state in await supabase.auth.authStateChanges {
        if [.initialSession, .signedIn, .signedOut].contains(state.event) {
          isAuthenticated = state.session != nil
        }
      }
    }
  }
}
