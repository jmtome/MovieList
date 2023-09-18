//
//  CodableMediaStoreTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 15/09/2023.
//

import XCTest
import MovieListFramework

final class CodableMediaStoreTests: XCTestCase, FailableMediaStoreSpecs {
    
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
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        //Given the SUT, the items, and the timestamp
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        //When the SUT inserts the items into the cache without error
        insert((items, timestamp), to: sut)

        //Then we expect that when the SUT retrieves, it retrieves the exact same items and timestamp we just inserted
        expect(sut, toRetrieve: .found(items: items, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let items = uniqueItems().local
        let timestamp = Date()
        
        insert((items, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(items: items, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        //Given a storeURL and an SUT created with that storeURL
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        //When we save some invalid data to the storeURL
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        //Then we expect to retrieve a failure, because we cannot decode that invalid data.
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        //Given a storeURL and an SUT created with that storeURL
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        //When we save some invalid data to the storeURL
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        //Then we expect to retrieve a failure, because we cannot decode that invalid data.
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueItems().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueItems().local, Date()), to: sut)
        
        let insertionError = insert((uniqueItems().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        insert((uniqueItems().local, Date()), to: sut)
        
        let latestMediaItems = uniqueItems().local
        let latestTimestamp = Date()
        insert((latestMediaItems, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(items: latestMediaItems, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let items = uniqueItems().local
        let timestamp = Date()
        
        let insertionError = insert((items, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let items = uniqueItems().local
        let timestamp = Date()
        
        insert((items, timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        insert((uniqueItems().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected existing cache to be deleted successfully")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueItems().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueItems().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedMedia { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueItems().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> MediaStore {
        let sut = CodableMediaStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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
