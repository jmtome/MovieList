//
//  Model.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import UIKit


typealias MediaTypeID = (type: MediaType, id: Int)

enum MediaType: Codable {
    case movie
    case tvshow
}

enum SortingOption: CaseIterable {
    case relevance
    case date
    case rating
    case title
    
    var title: String {
        switch self {
        case .relevance: return "Popularity"
        case .date: return "Date"
        case .rating: return "Rating"
        case .title: return "Name"
        }
    }
    
    var identifier: String {
        return "\(self)"
    }

    var image: UIImage {
        switch self {
        case .relevance: return UIImage(systemName: "chevron.up")!
        case .date: return UIImage(systemName: "chevron.up")!
        case .rating: return UIImage(systemName: "chevron.up")!
        case .title: return UIImage(systemName: "chevron.up")!
        }
    }
}

/*
 var adult: Bool? = nil
 var backdropPath: String? = nil
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
 var mediaImages: [MediaImage]? = nil
 
 var belongsToCollection: Collection? = nil
 var budget: Int? = nil
 var genres: [Genre]? = nil
 var homepage: String? = nil
 var imdbID: String? = nil
 var productionCompanies: [ProductionCompany]? = nil
 var productionCountries: [ProductionCountry]? = nil
 var revenue: Int? = nil
 var runtime: Int? = nil
 var spokenLanguages: [SpokenLanguage]? = nil
 var status: String? = nil
 var tagline: String? = nil
 var credits: MediaCredits? = nil
 */

struct MediaViewModel: Identifiable, Codable, Hashable {
    let id: Int
    let uuid: String
    let title: String
    let description: String
    let mainPosterURLString: String?
    
    let type: MediaType
    
    let dateAired: String
    let language: String
    
    let rating: Double
    let popularity: Double
    let voteCount: Int
    let voteAverage: Double
    
    var backdrops: [MediaImage]
    var posters: [MediaImage]
    
    var credits: MediaCredits?
    
    var runtime: [Int]
    
    var languages: [SpokenLanguage]
    
    var tagline: String?
    
    var seasons: Int?
    
    var genres: [Genre]
}
extension MediaViewModel {
    
}
extension MediaViewModel {
    init(tvshow: TVShow) {
        id = tvshow.id ?? 0
        uuid = tvshow.uuid
        title = tvshow.name ?? tvshow.originalName ?? "No Title"
        description = tvshow.overview ?? "No Overview for this show"
        mainPosterURLString = tvshow.fullPosterPath
        
        type = .tvshow
        
        dateAired = tvshow.releaseDate ?? "No Release Date"
        language = tvshow.originalLanguage ?? "No Language"
       
        rating = tvshow.voteAverage ?? 0.0
        popularity = tvshow.popularity ?? 0.0
        voteCount = tvshow.voteCount ?? 0
        voteAverage = tvshow.voteAverage ?? 0.0
        
        
        runtime = tvshow.episodeRunTime ?? []
        
        backdrops = []
        posters = [MediaImage(filePath: tvshow.fullPosterPath ?? "")]
        credits = tvshow.credits
        
        languages = tvshow.spokenLanguages ?? []
        
        tagline = tvshow.tagline
        
        seasons = tvshow.numberOfSeasons
        
        genres = tvshow.genres ?? []
    }
}
extension MediaViewModel {
    init(movie: Movie) {
        id = movie.id ?? 0
        uuid = movie.uuid
        title = movie.title ?? movie.originalTitle ?? "No Title"
        description = movie.overview ?? "No Overview for this movie"
        mainPosterURLString = movie.fullPosterPath
        
        type = .movie
        
        dateAired = movie.releaseDate ?? movie.firstAirDate ?? "No Release Date"
        language = movie.originalLanguage ?? "No Language"
        
        rating = movie.voteAverage ?? 0.0
        popularity = movie.popularity ?? 0.0
        voteCount = movie.voteCount ?? 0
        voteAverage = movie.voteAverage ?? 0.0
        
        runtime = [movie.runtime ?? -1]
        
        backdrops = []
        posters = [MediaImage(filePath: movie.fullPosterPath ?? "")]
        credits = movie.credits
        
        languages = movie.spokenLanguages ?? []
        
        tagline = movie.tagline
        
        seasons = nil
        
        genres = movie.genres ?? []
    }
}

extension MediaViewModel {
    func getStarRating() -> String {
        self.rating.getStarRating()
    }
    func getGenresAsString() -> String {
        return genres.compactMap { $0.name }.joined(separator: ", ")
    }
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





struct Response<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results, totalPages = "total_pages", totalResults = "total_results"
    }
}

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
