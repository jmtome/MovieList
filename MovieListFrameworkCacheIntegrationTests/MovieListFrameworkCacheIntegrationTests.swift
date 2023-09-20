//
//  MovieListFrameworkCacheIntegrationTests.swift
//  MovieListFrameworkCacheIntegrationTests
//
//  Created by macbook on 20/09/2023.
//

import XCTest
import MovieListFramework

final class MovieListFrameworkCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(mediaItems):
                XCTAssertEqual(mediaItems, [], "Expected empty array of items")
                
            case let .failure(error):
                XCTFail("Expected successfull mediaItems result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let items = uniqueItems().models
        
        let saveExp = expectation(description: "Wait for save completion")
        sutToPerformSave.save(items) { saveError in
            XCTAssertNil(saveError, "Expected to save media items successfully")
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 2.0)
        
        let loadExp = expectation(description: "Wait for load completion")
        sutToPerformLoad.load { loadResult in
            switch loadResult {
            case let .success(mediaItems):
                XCTAssertEqual(mediaItems, items)
                
            case let .failure(error):
                XCTFail("Expected successfull media items result, got \(error) instead")
            }
            
            loadExp.fulfill()
        }
        wait(for: [loadExp], timeout: 1.0)
    }
    

    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalMediaLoader {
        let storeBundle = Bundle(for: CoreDataMediaStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataMediaStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalMediaLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
