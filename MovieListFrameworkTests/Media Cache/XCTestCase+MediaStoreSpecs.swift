//
//  XCTestCase+MediaStoreSpecs.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 18/09/2023.
//

import XCTest
import MovieListFramework

extension MediaStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (items: [LocalMediaItem], timestamp: Date), to sut: MediaStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.items, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: MediaStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedMedia { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
 
    func expect(_ sut: MediaStore, toRetrieveTwice expectedResult: RetrieveCachedMediaItemsResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: MediaStore, toRetrieve expectedResult: RetrieveCachedMediaItemsResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
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
}
