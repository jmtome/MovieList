//
//  Movie.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import UIKit


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
}

struct TVShowMedia: Media {
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int?
    let originalLanguage: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    
    var name: String?
    var firstAirDate: String?
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case overview
        case popularity
        case posterPath = "poster_path"
        case name
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct MovieMedia: Media {
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int?
    let originalLanguage: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    
    var title: String?
    var releaseDate: String?
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, id, overview, genreIds, popularity
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case posterPath = "poster_path"
        case title
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}


struct Person: Codable, Hashable {
    let adult: Bool
    let gender: Int
    let id: Int
    let knownForDepartment: String
    let name: String
    let originalName: String
    let popularity: Double
    let profilePath: String?
    let knownFor: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, popularity, knownFor
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case profilePath = "profile_path"
    }
}

struct Movie: Codable, Hashable  {
    let adult: Bool?
    let backdropPath: String?
    let id: Int?
    let mediaType: String?
    let genreIds: [Int]?
    let originalLanguage: String?
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?
    let firstAirDate: String?
    let name: String?
    let originCountry: [String]?
    let popularity: Double?

    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, id, overview, video, title, name, genreIds, popularity
        case backdropPath = "backdrop_path"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
    }
}

struct TVShow: Codable, Hashable {
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalName: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let firstAirDate: String?
    let name: String
    let voteAverage: Double
    let voteCount: Int
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case popularity
        case posterPath = "poster_path"
        case firstAirDate = "first_air_date"
        case name
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
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

/*
 let decoder = JSONDecoder()

 // Decode PersonResponse
 let personResponse = try decoder.decode(Response<PersonResponse>.self, from: json)

 // Decode MovieResponse
 let movieResponse = try decoder.decode(Response<MovieResponse>.self, from: json)

 // Decode TVShowResponse
 let tvShowResponse = try decoder.decode(Response<TVShowResponse>.self, from: json)
 */


//struct PersonResponse: Codable {
//    let page: Int
//    let results: [Person]
//    let totalPages: Int
//    let totalResults: Int
//
//    enum CodingKeys: String, CodingKey {
//        case page, results, totalPages = "total_pages", totalResults = "total_results"
//    }
//}
//
//
//struct MovieResponse: Codable {
//    let page: Int
//    let results: [Movie]
//    let totalPages: Int
//    let totalResults: Int
//
//    enum CodingKeys: String, CodingKey {
//        case page
//        case results
//        case totalPages = "total_pages"
//        case totalResults = "total_results"
//    }
//}
//
//struct TVShowResponse: Codable {
//    let page: Int
//    let results: [TVShowResult]
//    let totalPages: Int
//    let totalResults: Int
//
//    enum CodingKeys: String, CodingKey {
//        case page
//        case results
//        case totalPages = "total_pages"
//        case totalResults = "total_results"
//    }
//}
