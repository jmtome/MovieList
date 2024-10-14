//
//  TrailingActionCircularImage.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 26/09/2024.
//

import SwiftUI

struct TrailingActionCircularImage: View {
//    @Binding var isFavorite: Bool
    var isFavorite: Bool
    private let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
    
    var body: some View {
        Image(uiImage: generateUIImage())
    }
    
    func generateUIImage() -> UIImage {
        let uimage = UIImage(systemName: isFavorite ? "star" : "star.fill", withConfiguration: largeConfig)?
            .withTintColor(.white, renderingMode: .alwaysTemplate)
            .addBackgroundCircle2(isFavorite ? .systemRed : .systemGreen) ?? UIImage()
        return uimage
    }
}

//#Preview {
////    TrailingActionCircularImage(isFavorite: .constant(true))
//    TrailingActionCircularImage(isFavorite: true)
//}

enum TrailingActionType {
    case favorite
    case bookmark
}

struct TrailingActionCircularImage2: View {
    var isActive: Bool
    var actionType: TrailingActionType
    
    private let largeConfig = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .bold, scale: .large)
    
    var body: some View {
        Image(uiImage: generateUIImage())
    }
    
    func generateUIImage() -> UIImage {
        let systemImageName: String
        let backgroundColor: UIColor
        
        switch actionType {
        case .favorite:
            systemImageName = isActive ? "star.fill" : "star"
            backgroundColor = isActive ? .systemRed : .systemGreen
        case .bookmark:
            systemImageName = isActive ? "bookmark.fill" : "bookmark"
            backgroundColor = isActive ? .systemBlue : .systemPurple
        }
        
        let uimage = UIImage(systemName: systemImageName, withConfiguration: largeConfig)?
            .withTintColor(.white, renderingMode: .alwaysTemplate)
            .addBackgroundCircle2(backgroundColor) ?? UIImage()
        
        return uimage
    }
}

#Preview {
    VStack {
        // Favorite Example
        TrailingActionCircularImage2(isActive: true, actionType: .favorite)
        
        // Bookmark Example
        TrailingActionCircularImage2(isActive: true, actionType: .bookmark)
    }
}
