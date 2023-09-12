//
//  CacheMediaUseCase.swift
//  MovieListFramework
//
//  Created by macbook on 12/09/2023.
//

import XCTest
import MovieListFramework

class LocalMediaLoader {
    private let store: MediaStore
    
    init(store: MediaStore) {
        self.store = store
    }
    
    func save(_ items: [MediaItem]) {
        store.deleteCachedMedia()
    }
}

class MediaStore {
    var deleteCachedMediaCallCount = 0

    func deleteCachedMedia() {
        deleteCachedMediaCallCount += 1
    }
}

class CacheMediaUseCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = MediaStore()
        _ = LocalMediaLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedMediaCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = MediaStore()
        let sut = LocalMediaLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedMediaCallCount, 1)
    }
    
    
    //MARK: - Helpers
    
    private func uniqueItem() -> MediaItem {
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
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
