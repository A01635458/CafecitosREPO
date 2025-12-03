//
//  ScansRow.swift
//  KaapehApp
//
//  Created by Admin on 03/12/25.
//

import SwiftUI

struct ScanRow: View {
    let scan: ScanModel

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {

                Text(scan.label)
                    .font(.headline)
                    .foregroundColor(.ka_coffee)

                Text(scan.info)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.leading)

                Divider()
                    .background(Color.ka_divider)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Fecha y hora de escaneo: \(scan.formattedDate)")
                        .font(.caption2)
                        .foregroundColor(.black.opacity(0.85))
                }
            }
        }
    }
}
