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
        store.deleteCachedMedia { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class MediaStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedMediaCallCount = 0
    var insertCallCount = 0

    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedMedia(completion: @escaping DeletionCompletion) {
        deleteCachedMediaCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [MediaItem]) {
        insertCallCount += 1
    }
}

class CacheMediaUseCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedMediaCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedMediaCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalMediaLoader, store: MediaStore) {
        let store = MediaStore()
        let sut = LocalMediaLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
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
    
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }
}
