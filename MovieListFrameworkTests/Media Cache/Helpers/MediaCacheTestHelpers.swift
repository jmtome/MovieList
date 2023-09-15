//
//  MediaCacheTestHelpers.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 14/09/2023.
//

import Foundation
import MovieListFramework

func uniqueItem() -> MediaItem {
    return MediaItem(adult: false,
                     backdropPath: anyURL().absoluteString,
                     genreIds: [],
                     id: UUID().hashValue,
                     mediaType: "any media",
                     originalLanguage: "any language",
                     originalTitle: "any og title",
                     overview: "any overview",
                     popularity: 0.0,
                     posterPath: anyURL().absoluteString,
                     releaseDate: "any date",
                     title: "any title",
                     video: false,
                     voteAverage: 0.0,
                     voteCount: 0)
}

func uniqueItems() -> (models: [MediaItem], local: [LocalMediaItem]) {
    let models = [uniqueItem(), uniqueItem()]
    let local = models.map { LocalMediaItem(adult: $0.adult, backdropPath: $0.backdropPath, genreIds: $0.genreIds, id: $0.id, mediaType: $0.mediaType, originalLanguage: $0.originalLanguage, originalTitle: $0.originalTitle, overview: $0.overview, popularity: $0.popularity, posterPath: $0.posterPath, releaseDate: $0.releaseDate, title: $0.title, video: $0.video, voteAverage: $0.voteAverage, voteCount: $0.voteCount) }
    return (models, local)
}


extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -7)
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
