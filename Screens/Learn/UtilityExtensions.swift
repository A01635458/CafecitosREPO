//
//  UtilityExtensions.swift
//  KaapehApp
//
//  Created by Alumno on 01/12/25.
//

import SwiftUI

// MARK: - Extensión para Strings Opcionales
extension Binding where Value == String? {
    var bound: Binding<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - Extensión para Módulos Opcionales
extension Binding where Value == ModuleDTO? {
    var isNotNil: Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { isPresenting in
                if !isPresenting {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

// MARK: - Extensión para Lecciones Opcionales
extension Binding where Value == LessonDTO? {
    var isNotNil: Binding<Bool> {
        return Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { isPresenting in
                if !isPresenting {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

