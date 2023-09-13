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
    private let currentDate: () -> Date
    
    init(store: MediaStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [MediaItem]) {
        store.deleteCachedMedia { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class MediaStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedMediaCallCount = 0
    var insertions = [(items: [MediaItem], timestamp: Date)]()
    
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
    
    func insert(_ items: [MediaItem], timestamp: Date) {
        insertions.append((items, timestamp))
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
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalMediaLoader, store: MediaStore) {
        let store = MediaStore()
        let sut = LocalMediaLoader(store: store, currentDate: currentDate)
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
