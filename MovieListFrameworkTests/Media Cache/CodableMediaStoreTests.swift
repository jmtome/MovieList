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
        let items: [LocalMediaItem]
        let timestamp: Date
    }
    
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "media-items.store")
    
    func insert(_ items: [LocalMediaItem],
                timestamp: Date,
                completion: @escaping MediaStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(items: items, timestamp: timestamp))
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
    
    func retrieve(completion: @escaping MediaStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
            
        completion(.found(items: cache.items, timestamp: cache.timestamp))
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
        let sut = CodableMediaStore()
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
        let sut = CodableMediaStore()
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
        let sut = CodableMediaStore()
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
}
