import SwiftUI

extension View {
    func card() -> some View {
        self
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
//
//  View+Card.swift
//  PayShare
//
//  Created by Neel Shah on 2026-01-25.
//

