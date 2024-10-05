//
//  TVShow.swift
//  MovieList
//
//  Created by macbook on 25/05/2023.
//

import Foundation

struct TVShow: Media, Codable, Hashable {
    var uuid: String = UUID().uuidString
    
    var mediaType: String?
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
    var mediaImages: [MediaImage]? = nil
    
    
    let createdBy: [Creator]?
    let episodeRunTime: [Int]?
    let genres: [Genre]?
    let homepage: String?
    let inProduction: Bool?
    let languages: [String]?
    let lastAirDate: String?
    let lastEpisodeToAir: Episode?
    let networks: [Network]?
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    let originCountry: [String]?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let seasons: [Season]?
    let spokenLanguages: [SpokenLanguage]?
    let status: String?
    let tagline: String?
    
    let credits: MediaCredits?
    let videos: VideoResults?
    
    var fullPosterPath: String? {
        guard let posterPath = posterPath else {
            return nil
        }
        print("#### posterpath tvshow: \(posterPath)")

//        return posterPath
        return "https://image.tmdb.org/t/p/w154/\(posterPath)"
    }
    
    init(mediaType: String? = nil, adult: Bool? = nil, backdropPath: String? = nil, genreIds: [Int]? = nil, id: Int? = nil, originalLanguage: String? = nil, originalName: String? = nil, overview: String? = nil, popularity: Double? = nil, posterPath: String? = nil, releaseDate: String? = nil, name: String? = nil, voteAverage: Double? = nil, voteCount: Int? = nil, createdBy: [Creator]? = nil, episodeRunTime: [Int]? = nil, firstAirDate: String? = nil, genres: [Genre]? = nil, homepage: String? = nil, inProduction: Bool? = nil, languages: [String]? = nil, lastAirDate: String? = nil, lastEpisodeToAir: Episode? = nil, networks: [Network]? = nil, numberOfEpisodes: Int? = nil, numberOfSeasons: Int? = nil, originCountry: [String]? = nil, productionCompanies: [ProductionCompany]? = nil, productionCountries: [ProductionCountry]? = nil, seasons: [Season]? = nil, spokenLanguages: [SpokenLanguage]? = nil, status: String? = nil, tagline: String? = nil, credits: MediaCredits? = nil, videos: VideoResults? = nil) {
        self.mediaType = mediaType
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
        self.createdBy = createdBy
        self.episodeRunTime = episodeRunTime
        self.genres = genres
        self.homepage = homepage
        self.inProduction = inProduction
        self.languages = languages
        self.lastAirDate = lastAirDate
        self.lastEpisodeToAir = lastEpisodeToAir
        self.networks = networks
        self.numberOfEpisodes = numberOfEpisodes
        self.numberOfSeasons = numberOfSeasons
        self.originCountry = originCountry
        self.productionCompanies = productionCompanies
        self.productionCountries = productionCountries
        self.seasons = seasons
        self.spokenLanguages = spokenLanguages
        self.status = status
        self.tagline = tagline
        self.credits = credits
        self.videos = videos
    }
    
    //    init() {
    //        self.init(id: -1, name: "Fav TVShow to display.")
    //    }
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
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
        case name
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case createdBy = "created_by"
        case episodeRunTime = "episode_run_time"
        case genres
        case homepage
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
        case networks
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case seasons
        case spokenLanguages = "spoken_languages"
        case status
        case tagline
        case credits
        case videos 
    }
}



struct Creator: Codable, Hashable {
    let id: Int?
    let creditID: String?
    let name: String?
    let gender: Int?
    let profilePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case creditID = "credit_id"
        case name
        case gender
        case profilePath = "profile_path"
    }
}

struct Episode: Codable, Hashable {
    let id: Int?
    let name: String?
    let overview: String?
    let voteAverage: Double?
    let voteCount: Int?
    let airDate: String?
    let episodeNumber: Int?
    let productionCode: String?
    let runtime: Int?
    let seasonNumber: Int?
    let showID: Int?
    let stillPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case productionCode = "production_code"
        case runtime
        case seasonNumber = "season_number"
        case showID = "show_id"
        case stillPath = "still_path"
    }
}

struct Network: Codable, Hashable {
    let id: Int?
    let logoPath: String?
    let name: String?
    let originCountry: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

struct Season: Codable, Hashable {
    let airDate: String?
    let episodeCount: Int?
    let id: Int?
    let name: String?
    let overview: String?
    let posterPath: String?
    let seasonNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}

