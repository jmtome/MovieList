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
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        //Given the SUT, the items, and the timestamp
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        //When the SUT inserts the items into the cache without error
        insert((items, timestamp), to: sut)

        //Then we expect that when the SUT retrieves, it retrieves the exact same items and timestamp we just inserted
        expect(sut, toRetrieve: .found(items: items, timestamp: timestamp))
    }
    
    func test_retrieveHasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        insert((items, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(items: items, timestamp: timestamp))
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableMediaStore {
        let sut = CodableMediaStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableMediaStore, toRetrieveTwice expectedResult: RetrieveCachedMediaItemsResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func insert(_ cache: (items: [LocalMediaItem], timestamp: Date), to sut: CodableMediaStore) {
        let exp = expectation(description: "Wait for cache insertion")
        sut.insert(cache.items, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CodableMediaStore, toRetrieve expectedResult: RetrieveCachedMediaItemsResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
                
            case let (.found(expectedItems, expectedTimestamp), .found(retrievedItems, retrievedTimestamp)):
                XCTAssertEqual(expectedItems, retrievedItems, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
