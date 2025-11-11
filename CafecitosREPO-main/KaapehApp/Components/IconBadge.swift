//
//  IconBadge.swift
//  KaapehApp
//

import SwiftUI

struct IconBadge: View {
let systemName: String
let tint: Color
var body: some View {
Image(systemName: systemName)
.font(.system(size: 20, weight: .semibold))
.foregroundStyle(tint)
.frame(width: 52, height: 52)
.background(tint.opacity(0.08))
.clipShape(Circle())
}
}
