////
////  CodableMediaStoreTests.swift
////  MovieListFrameworkTests
////
////  Created by macbook on 15/09/2023.
////
//
//import XCTest
//import MovieListFramework
//
//final class CodableMediaStoreTests: XCTestCase, FailableMediaStoreSpecs {
//    
//    override func setUp() {
//        super.setUp()
//        
//        setupEmptyStoreState()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//
//        undoStoreSideEffects()
//    }
//    
//    func test_retrieve_deliversEmptyOnEmptyCache() {
//        let sut = makeSUT()
//        
//        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
//    }
//    
//    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//        
//        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
//    }
//    
//    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()
//      
//        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
//    }
//    
//    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
//    }
//    
//    func test_retrieve_deliversFailureOnRetrievalError() {
//        //Given a storeURL and an SUT created with that storeURL
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        
//        //When we save some invalid data to the storeURL
//        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
//        
//        //Then we expect to retrieve a failure, because we cannot decode that invalid data.
//        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//    }
//    
//    func test_retrieve_hasNoSideEffectsOnFailure() {
//        //Given a storeURL and an SUT created with that storeURL
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        
//        //When we save some invalid data to the storeURL
//        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
//        
//        //Then we expect to retrieve a failure, because we cannot decode that invalid data.
//        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//    }
//    
//    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
//    }
//    
//    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//      
//        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
//    }
//    
//    func test_insert_overridesPreviouslyInsertedCacheValues() {
//        let sut = makeSUT()
//        
//        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
//    }
//    
//    func test_insert_deliversErrorOnInsertionError() {
//        let invalidStoreURL = URL(string: "invalid://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//        
//        assertThatInsertDeliversErrorOnInsertionError(on: sut)
//    }
//    
//    func test_insert_hasNoSideEffectsOnInsertionError() {
//        let invalidStoreURL = URL(string: "invalid://store-url")!
//        let sut = makeSUT(storeURL: invalidStoreURL)
//  
//        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//    }
//    
//    func test_delete_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//        
//        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
//    }
//    
//    func test_delete_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//        
//        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
//    }
//    
//    func test_delete_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
//    }
//    
//    func test_delete_emptiesPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
//    }
//    
//    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//        
//        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//    }
//    
//    func test_delete_hasNoSideEffectsOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory()
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//        
//        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//    }
//    
//    func test_storeSideEffects_runSerially() {
//        let sut = makeSUT()
//      
//        assertThatSideEffectsRunSerially(on: sut)
//    }
//    
//    //MARK: - Helpers
//    
//    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> MediaStore {
//        let sut = CodableMediaStore(storeURL: storeURL ?? testSpecificStoreURL())
//        trackForMemoryLeaks(sut, file: file, line: line)
//        return sut
//    }
//    
//    private func testSpecificStoreURL() -> URL {
//        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
//    }
//    
//    private func cachesDirectory() -> URL {
//        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
//    }
//    
//    private func setupEmptyStoreState() {
//        deleteStoreArtifacts()
//    }
//    
//    private func undoStoreSideEffects() {
//        deleteStoreArtifacts()
//    }
//    
//    private func deleteStoreArtifacts() {
//        try? FileManager.default.removeItem(at: testSpecificStoreURL())
//    }
//}
