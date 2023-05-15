//
//  Movie.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import UIKit

struct AnyMedia: Hashable {
    private let _base: any Media
    
    init<T: Media>(_ base: T) {
        _base = base
    }

    var id: Int {
        _base.id ?? -1
    }
    
    var uuid: String {
        _base.uuid
    }
    
    var title: String {
        _base.title ?? "Err title"
    }

    var overview: String {
        guard let overview = _base.overview, !overview.isEmpty else {
            return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent vel dolor risus. Sed interdum, nisi quis ornare luctus, eros urna pellentesque elit, quis venenatis dolor odio eu lectus. Etiam nec felis orci. "
        }
        return overview
    }

    var voteAverage: Double {
        _base.voteAverage ?? 0.0
    }

    var releaseDate: String {
        _base.releaseDate ?? "Err date"
    }

    var fullPosterPath: String? {
        _base.fullPosterPath
    }

    var popularity: Double {
        _base.popularity ?? 0.0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(_base.uuid)
        hasher.combine(_base.id)
    }

    func mediaType() -> any Media.Type {
        if let movie = _base as? Movie {
            return type(of: movie)
        } else if let tvShow = _base as? TVShow {
            return type(of: tvShow)
        } else {
            fatalError()
        }
    }
    func getBaseType() -> (any Media)? {
        mediaType() == Movie.self ? _base as? Movie : _base as? TVShow
    }
    
    static func ==(lhs: AnyMedia, rhs: AnyMedia) -> Bool {
//        return lhs._base.id == rhs._base.id
        return lhs._base.uuid == rhs._base.uuid
    }
}
//
//extension AnyMedia {
//    // MARK: - Codable
//
////    enum CodingKeys: String, CodingKey {
////
////
////
////    }
//
//
//    init(from decoder: Decoder) throws {
//
//        let container = try decoder.singleValueContainer()
//
//        if let tvShow = try? container.decode(TVShow.self),
//           let name = tvShow.name, !name.isEmpty {
//            _base = tvShow
//        } else if let movie = try? container.decode(Movie.self) {
//            _base = movie
//        } else {
//            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid data")
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        if let movie = _base as? Movie {
//            try container.encode(movie)
//        } else if let tvShow = _base as? TVShow {
//            try container.encode(tvShow)
//        } else {
//            throw EncodingError.invalidValue(_base, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid data"))
//        }
//    }
//}






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

struct Movie: Media, Codable, Hashable  {
    var uuid: String = UUID().uuidString
    
    var adult: Bool? = nil
    var backdropPath: String? = nil
    var id: Int? = nil
    var mediaType: String? = nil
    var genreIds: [Int]? = nil
    var originalLanguage: String? = nil
    var originalTitle: String? = nil
    var overview: String? = nil
    var posterPath: String? = nil
    var releaseDate: String? = nil
    var title: String? = nil
    var video: Bool? = nil
    var voteAverage: Double? = nil
    var voteCount: Int? = nil
    var firstAirDate: String? = nil
    var originCountry: [String]? = nil
    var popularity: Double? = nil
 
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    internal init(adult: Bool? = nil, backdropPath: String? = nil, id: Int? = nil, mediaType: String? = nil, genreIds: [Int]? = nil, originalLanguage: String? = nil, originalTitle: String? = nil, overview: String? = nil, posterPath: String? = nil, releaseDate: String? = nil, title: String? = nil, video: Bool? = nil, voteAverage: Double? = nil, voteCount: Int? = nil, firstAirDate: String? = nil, originCountry: [String]? = nil, popularity: Double? = nil) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.id = id
        self.mediaType = mediaType
        self.genreIds = genreIds
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.title = title
        self.video = video
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.firstAirDate = firstAirDate
        self.originCountry = originCountry
        self.popularity = popularity
    }
    
    init() {
        self.init(id: -2, title: "Fav Movie to display.")
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, id, overview, video, title, genreIds, popularity
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

struct TVShow: Media, Codable, Hashable {
    var uuid: String = UUID().uuidString
    
    let adult: Bool?
    let backdropPath: String?
    let genreIds: [Int]?
    let id: Int?
    let originalLanguage: String?
    let originalName: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    let releaseDate: String?
    var title: String? {
        return name
    }
    let name: String?
    let voteAverage: Double?
    let voteCount: Int?
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    init(adult: Bool? = nil, backdropPath: String? = nil, genreIds: [Int]? = nil, id: Int? = nil, originalLanguage: String? = nil, originalName: String? = nil, overview: String? = nil, popularity: Double? = nil, posterPath: String? = nil, releaseDate: String? = nil, name: String? = nil, voteAverage: Double? = nil, voteCount: Int? = nil) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.genreIds = genreIds
        self.id = id
        self.originalLanguage = originalLanguage
        self.originalName = originalName
        self.overview = overview
        self.popularity = popularity
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.name = name
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
    
    init() {
        self.init(id: -1, name: "Fav TVShow to display.")
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
        case releaseDate = "first_air_date"
        case name = "name"
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
extension Response {
    static func response(for scope: SearchScope, data: Data) -> Response<T>? {
        switch scope {
        case .series:
            guard let tvShowResponse = try? JSONDecoder().decode(Response<TVShow>.self, from: data) else {
                return nil
            }
            return Response<T>(page: tvShowResponse.page, results: tvShowResponse.results as! [T], totalPages: tvShowResponse.totalPages, totalResults: tvShowResponse.totalResults)
        case .movies:
            guard let movieResponse = try? JSONDecoder().decode(Response<Movie>.self, from: data) else {
                return nil
            }
            return Response<T>(page: movieResponse.page, results: movieResponse.results as! [T], totalPages: movieResponse.totalPages, totalResults: movieResponse.totalResults)
        default: return nil
        }
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
