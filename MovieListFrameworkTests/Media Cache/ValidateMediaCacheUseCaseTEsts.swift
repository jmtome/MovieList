//
//  ValidateMediaCacheUseCaseTEsts.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 14/09/2023.
//

import XCTest
import MovieListFramework

final class ValidateMediaCacheUseCaseTEsts: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    //MARK: - Helperrs
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalMediaLoader, store: MediaStoreSpy) {
        let store = MediaStoreSpy()
        let sut = LocalMediaLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }

}
