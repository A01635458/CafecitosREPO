//
//  Theme.swift
//  KaapehApp
//


import SwiftUI

extension Color {
static let ka_bg = Color(red: 0.98, green: 0.97, blue: 0.96) // #FAF7F4 aprox
static let ka_surface = Color.white
static let ka_divider = Color(red: 0.90, green: 0.91, blue: 0.92) // #E5E7EB aprox
static let ka_coffee = Color(red: 0.545, green: 0.27, blue: 0.074) // #8B4513
static let ka_warn = Color(red: 1.00, green: 0.95, blue: 0.78) // #FEF3C7 aprox
static let ka_warnText = Color(red: 0.57, green: 0.25, blue: 0.06)// #92400E aprox
}


struct Card<Content: View>: View {
let padding: CGFloat
@ViewBuilder var content: Content
init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
self.padding = padding
self.content = content()
}
var body: some View {
content
.padding(padding)
.background(Color.ka_surface)
.overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.ka_divider))
.clipShape(RoundedRectangle(cornerRadius: 16))
}
}
