//
//  LocalMediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 13/09/2023.
//

import Foundation

public final class LocalMediaLoader {
    private let store: MediaStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: MediaStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [MediaItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedMedia { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    public func load() {
        store.retrieve()
    }
    
    private func cache(_ items: [MediaItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == MediaItem {
    func toLocal() -> [LocalMediaItem] {
        return map { LocalMediaItem(adult: $0.adult, backdropPath: $0.backdropPath, genreIds: $0.genreIds, id: $0.id, mediaType: $0.mediaType, originalLanguage: $0.originalLanguage, originalTitle: $0.originalTitle, overview: $0.overview, popularity: $0.popularity, posterPath: $0.posterPath, releaseDate: $0.releaseDate, title: $0.title, video: $0.video, voteAverage: $0.voteAverage, voteCount: $0.voteCount) }
    }
}
