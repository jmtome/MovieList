//
//  MediaViewModel.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation
import MovieListFramework

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
    var videos: [Video]
    
    var credits: MediaCredits?
    var countryWatchProviders: CountryWatchProviders?
    var runtime: [Int]
    
    var languages: [SpokenLanguage]
    
    var tagline: String?
    
    var seasons: Int?
    
    var genres: [Genre]
    var isFavorite: Bool = false
}

extension MediaViewModel {
    static func viewModelFrom(mediaItem: MediaItem) -> MediaViewModel {
        let uuid = UUID().uuidString
        return MediaViewModel(id: mediaItem.id,
                              uuid: uuid,
                              title: mediaItem.title,
                              description: mediaItem.overview,
                              mainPosterURLString: mediaItem.posterPath,
                              type: .movie,
                              dateAired: "12-10-2020",
                              language: "Eng",
                              rating: mediaItem.voteAverage,
                              popularity: mediaItem.popularity,
                              voteCount: mediaItem.voteCount,
                              voteAverage: mediaItem.voteAverage,
                              backdrops: [],
                              posters: [],
                              videos: [],
                              runtime: [],
                              languages: [],
                              genres: [])
    }
}

extension MediaViewModel {
    init(_ credits: MediaCredits? = nil) {
        self.type = .movie
        self.id = 0
        self.title = "Loading..."
        self.backdrops = []
        self.dateAired = "200 years ago"
        self.uuid = UUID().uuidString
        self.mainPosterURLString = ""
        self.language = ""
        self.credits = credits
        self.posters = []
        self.videos = []
        self.description = ""
        self.runtime = []
        self.voteAverage = 0
        self.voteCount = 0
        self.genres = []
        self.languages = []
        self.tagline = ""
        self.seasons = 0
        self.rating = 0
        self.popularity = 0
    }
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
        videos = tvshow.videos?.results ?? []
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
        videos = movie.videos?.results ?? []
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
