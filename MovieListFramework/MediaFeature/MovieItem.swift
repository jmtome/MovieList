//
//  MovieItem.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

public typealias MediaItem = MovieItem

public struct MovieItem: Equatable {
    public let adult: Bool
    public let backdropPath: String?
    public let genreIds: [Int]
    public let id: UUID
    public let mediaType: String?
    public let originalLanguage: String
    public let originalTitle: String
    public let overview: String
    public let popularity: Double
    public let posterPath: String?
    public let releaseDate: String
    public let title: String
    public let video: Bool
    public let voteAverage: Double
    public let voteCount: Int
    
    public init(adult: Bool, backdropPath: String? = nil, genreIds: [Int], id: UUID, mediaType: String? = nil, originalLanguage: String, originalTitle: String, overview: String, popularity: Double, posterPath: String? = nil, releaseDate: String, title: String, video: Bool, voteAverage: Double, voteCount: Int) {
        self.adult = adult
        self.backdropPath = backdropPath
        self.genreIds = genreIds
        self.id = id
        self.mediaType = mediaType
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.overview = overview
        self.popularity = popularity
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.title = title
        self.video = video
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
}

