//
//  Movie.swift
//  MovieList
//
//  Created by macbook on 25/05/2023.
//

import Foundation


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
    
    var videos: VideoResults? = nil
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
    
    internal init(adult: Bool? = nil, backdropPath: String? = nil, id: Int? = nil, mediaType: String? = nil, genreIds: [Int]? = nil, originalLanguage: String? = nil, originalTitle: String? = nil, overview: String? = nil, posterPath: String? = nil, releaseDate: String? = nil, title: String? = nil, video: Bool? = nil, voteAverage: Double? = nil, voteCount: Int? = nil, firstAirDate: String? = nil, originCountry: [String]? = nil, popularity: Double? = nil, credits: MediaCredits? = nil, videos: VideoResults? = nil) {
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
        self.credits = credits
        self.videos = videos
    }
    
    init() {
        self.init(id: -2, title: "Fav Movie to display.")
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, id, overview, video, videos, title, genreIds, popularity
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
        case belongsToCollection = "belongs_to_collection"
        case budget, genres, homepage
        case imdbID = "imdb_id"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline
    }
}


struct Collection: Codable, Hashable {
    var id: Int? = nil
    var name: String? = nil
    var posterPath: String? = nil
    var backdropPath: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

struct Genre: Codable, Hashable {
    var id: Int? = nil
    var name: String? = nil
}

struct ProductionCompany: Codable, Hashable {
    var id: Int? = nil
    var logoPath: String? = nil
    var name: String? = nil
    var originCountry: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}

struct ProductionCountry: Codable, Hashable {
    var iso3166_1: String? = nil
    var name: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case iso3166_1
        case name
    }
}

struct SpokenLanguage: Codable, Hashable {
    var englishName: String? = nil
    var iso639_1: String? = nil
    var name: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1
        case name
    }
}

struct MediaCredits: Codable, Hashable {
    let id: Int
    let cast: [Cast]
    let crew: [Crew]
    
    enum CodingKeys: String, CodingKey {
        case id, cast, crew
    }
}

struct Cast: Codable, Hashable {
    let adult: Bool
    let gender: Int
    let id: Int
    let knownForDepartment: String
    let name: String
    let originalName: String
    let popularity: Double
    let profilePath: String?
    let castID: Int?
    let character: String
    let creditID: String
    let order: Int
    
    var profilePicturePath: String? {
        guard let profilePath = profilePath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(profilePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, popularity, character, order
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case profilePath = "profile_path"
        case castID = "cast_id"
        case creditID = "credit_id"
    }
}

struct Crew: Codable, Hashable {
    let adult: Bool
    let gender: Int
    let id: Int
    let knownForDepartment: String
    let name: String
    let originalName: String
    let popularity: Double
    let profilePath: String?
    let creditID: String
    let department: String
    let job: String
    
    var profilePicturePath: String? {
        guard let profilePath = profilePath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(profilePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, popularity, department, job
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case profilePath = "profile_path"
        case creditID = "credit_id"
    }
}

