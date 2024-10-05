//
//  MediaImage.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation

struct MediaImage: Codable, Hashable {
    let aspectRatio: Double
    let height: Int
    let iso639_1: String?
    let filePath: String
    let voteAverage: Double
    let voteCount: Int
    let width: Int

    var fullImagePath: String {
        return "https://image.tmdb.org/t/p/w500/\(filePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case height
        case iso639_1
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case width
    }
}
extension MediaImage {
    init(filePath: String) {
        aspectRatio = 0.0
        height = 0
        iso639_1 = nil
        self.filePath = filePath
        voteAverage = 0.0
        voteCount = 0
        width = 0
    }
}
