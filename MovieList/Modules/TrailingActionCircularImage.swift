//
//  TrailingActionCircularImage.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 26/09/2024.
//

import SwiftUI

struct TrailingActionCircularImage: View {
    @Binding var isFavorite: Bool
    private let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
    
    var body: some View {
        Image(uiImage: generateUIImage())
    }
    
    func generateUIImage() -> UIImage {
        let uimage = UIImage(systemName: isFavorite ? "star" : "star.fill", withConfiguration: largeConfig)?
            .withTintColor(.white, renderingMode: .alwaysTemplate)
            .addBackgroundCircle(isFavorite ? .systemRed : .systemGreen) ?? UIImage()
        return uimage
    }
}

#Preview {
    TrailingActionCircularImage(isFavorite: .constant(true))
}
