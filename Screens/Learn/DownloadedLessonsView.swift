//
//  DownloadedLessonsView.swift
//  KaapehApp
//
//  Created by Ivan Ornelas on 04/12/25.
//

import SwiftUI
import SwiftData
struct DownloadedLessonsView: View {
    
    @Query(sort: [SortDescriptor(\LessonEntity.createdAt, order: .forward)])
    private var downloadedLessons: [LessonEntity]
    var body: some View {
        VStack(spacing: 0) {
            Text("Lecciones Descargadas")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)
                .padding(.horizontal, 20)
            
            if downloadedLessons.isEmpty {
                VStack {
                    Image(systemName: "tray.and.arrow.down.fill")
                        .font(.largeTitle)
                        .padding()
                    Text("No hay lecciones guardadas")
                        .font(.headline)
                    Text("Descarga el contenido desde la pestaña 'Aprender' para verlo sin conexión.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 80)
                .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Lecciones descargadas: \(downloadedLessons.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 10)
                        
                        ForEach(downloadedLessons) { lessonEntity in
                            DownloadedLessonCard(lessonEntity: lessonEntity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Offline")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.ka_bg.ignoresSafeArea(.all, edges: .bottom))
    }
}
private struct DownloadedLessonCard: View {
    let lessonEntity: LessonEntity
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text(lessonEntity.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                Text(previewText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var previewText: String {
        if lessonEntity.content.count > 80 {
            return String(lessonEntity.content.prefix(80)) + "…"
        } else {
            return lessonEntity.content
        }
    }
}
