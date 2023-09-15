//
//  CodableMediaStoreTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 15/09/2023.
//

import XCTest
import MovieListFramework

class CodableMediaStore {
    private struct Cache: Codable {
        let items: [CodableMediaItem]
        let timestamp: Date
        
        var localFeed: [LocalMediaItem] {
            return items.map { $0.local }
        }
    }
    
    private struct CodableMediaItem: Codable {
        private let adult: Bool
        private let backdropPath: String?
        private let genreIds: [Int]
        private let id: Int
        private let mediaType: String?
        private let originalLanguage: String
        private let originalTitle: String
        private let overview: String
        private let popularity: Double
        private let posterPath: String?
        private let releaseDate: String
        private let title: String
        private let video: Bool
        private let voteAverage: Double
        private let voteCount: Int
        
        init(_ media: LocalMediaItem) {
            adult = media.adult
            backdropPath = media.backdropPath
            genreIds = media.genreIds
            id = media.id
            mediaType = media.mediaType
            originalLanguage = media.originalLanguage
            originalTitle = media.originalTitle
            overview = media.overview
            popularity = media.popularity
            posterPath = media.posterPath
            releaseDate = media.releaseDate
            title = media.title
            video = media.video
            voteAverage = media.voteAverage
            voteCount = media.voteCount
        }
        
        var local: LocalMediaItem {
            return LocalMediaItem(adult: adult, backdropPath: backdropPath, genreIds: genreIds, id: id, mediaType: mediaType, originalLanguage: originalLanguage, originalTitle: originalTitle, overview: overview, popularity: popularity, posterPath: posterPath, releaseDate: releaseDate, title: title, video: video, voteAverage: voteAverage, voteCount: voteCount)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping MediaStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(items: items.map(CodableMediaItem.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    
    func retrieve(completion: @escaping MediaStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(items: cache.localFeed, timestamp: cache.timestamp))
    }
}

final class CodableMediaStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "media-items.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "media-items.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(items, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(items: retrievedMediaItems, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedMediaItems, items)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    
                default:
                    XCTFail("Expected found result with feed \(items) and timestamp \(timestamp) got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableMediaStore {
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "media-items.store")
        let sut = CodableMediaStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
