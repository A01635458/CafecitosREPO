//
//  RoastingLessonView.swift
//  KaapehApp
//
//  Created by Luisa Cardona on 07/11/25.
//

import Foundation
import SwiftUI

struct RoastingLessonView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image("roasting")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Text("Tueste y Aroma")
                    .font(.system(size: 24, weight: .bold))
                Text("Durante el tueste, los granos cambian químicamente. El color, aroma y sabor se desarrollan en esta etapa crucial. Los tuestes claros resaltan la acidez y las notas frutales; los oscuros, los sabores tostados y amargos.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Tueste y Aroma")
        .background(Color.ka_bg)
    }
}

