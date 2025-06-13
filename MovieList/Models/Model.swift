//
//  Model.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import UIKit
import SwiftUI
import MovieListFramework

typealias MediaTypeID = (type: MediaType, id: Int)

enum MediaType: Codable {
    case movie
    case tvshow
}

protocol Media: Codable, Hashable {
    var adult: Bool? { get }
    var backdropPath: String? { get }
    var genreIds: [Int]? { get }
    var id: Int? { get }
    var originalLanguage: String? { get }
    var overview: String? { get }
    var popularity: Double? { get }
    var posterPath: String? { get }
    var voteAverage: Double? { get }
    var voteCount: Int? { get }
    var fullPosterPath: String? { get }
    var title: String? { get }
    var releaseDate: String? { get }
    var uuid: String { get }
    var mediaImages: [MediaImage]? { get set }
}

struct MovieCredits: Codable {
    let cast: [Movie]
    let crew: [Movie]
}

struct Response<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results, totalPages = "total_pages", totalResults = "total_results"
    }
}

struct ImagesResponse: Codable {
    let backdrops: [MediaImage]
    let posters: [MediaImage]
}

enum Section: String, Hashable {
    case movies = "Movies"
    case tvshows = "TV Shows"
    case popularMovies = "Popular Movies"
    case popularShows = "Popular Shows"
    case favoritesMovies = "Favorite Movies"
    case favoriteShows = "Favorite Shows"
}

