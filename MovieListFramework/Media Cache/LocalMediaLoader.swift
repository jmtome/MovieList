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
        
    public init(store: MediaStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalMediaLoader {
    public typealias SaveResult = Error?
    
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
    
    private func cache(_ items: [MediaItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalMediaLoader: MediaLoader {
    public typealias LoadResult = MediaLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(items: localItems, timestamp: timestamp) where MediaCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(localItems.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalMediaLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedMedia { _ in }
                
            case let .found(items: _, timestamp: timestamp) where !MediaCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedMedia { _ in }
                
            case .empty, .found: break
            }
        }
    }
}

private extension Array where Element == MediaItem {
    func toLocal() -> [LocalMediaItem] {
        return map { LocalMediaItem(adult: $0.adult, backdropPath: $0.backdropPath, genreIds: $0.genreIds, id: $0.id, mediaType: $0.mediaType, originalLanguage: $0.originalLanguage, originalTitle: $0.originalTitle, overview: $0.overview, popularity: $0.popularity, posterPath: $0.posterPath, releaseDate: $0.releaseDate, title: $0.title, video: $0.video, voteAverage: $0.voteAverage, voteCount: $0.voteCount) }
    }
}

private extension Array where Element == LocalMediaItem {
    func toModels() -> [MediaItem] {
        return map { MediaItem(adult: $0.adult, backdropPath: $0.backdropPath, genreIds: $0.genreIds, id: $0.id, mediaType: $0.mediaType, originalLanguage: $0.originalLanguage, originalTitle: $0.originalTitle, overview: $0.overview, popularity: $0.popularity, posterPath: $0.posterPath, releaseDate: $0.releaseDate, title: $0.title, video: $0.video, voteAverage: $0.voteAverage, voteCount: $0.voteCount) }
    }
}
