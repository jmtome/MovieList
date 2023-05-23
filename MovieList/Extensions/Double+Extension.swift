//
//  Double+Extension.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import Foundation

extension Double {
    func getStarRating() -> String {
        let fullStar = "★"
        let halfStar = "½"
        let emptyStar = "☆"
        
        // Ensure the value is within the range of 0 to 10.0
        let clampedValue = max(0, min(self, 10.0))
        
        // Calculate the number of full stars
        let fullStars = Int(clampedValue / 2)
        
        // Check if there's a half star
        let hasHalfStar = (clampedValue - Double(fullStars * 2)) >= 1.0
        
        // Create the star rating string
        var starRating = String(repeating: fullStar, count: fullStars)
        
        if hasHalfStar {
            starRating += halfStar
        }
        
        let remainingStars = 5 - starRating.count
        starRating += String(repeating: emptyStar, count: remainingStars)
        
        return starRating
    }
}
