//
//  SearchScope.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation

enum SearchScope: Int {
    case movies
    case series
    
    var displayTitle: String {
        switch self {
        case .movies:
            return "Movies"
        case .series:
            return "Series"
        }
    }
    
    var urlAppendix: String {
        switch self {
        case .movies: return "movies"
        case .series: return "tv"
        }
    }
    
    var resultType: Codable.Type {
        switch self {
        case .movies: return Movie.self
        case .series: return TVShow.self
        }
    }
}
