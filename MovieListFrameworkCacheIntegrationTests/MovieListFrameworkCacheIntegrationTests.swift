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
        
        expect(sut, toLoad: [])
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
        
        expect(sutToPerformLoad, toLoad: items)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstMediaItems = uniqueItems().models
        let lastMediaItems = uniqueItems().models
        
        let saveExp1 = expectation(description: "Wait for save completion")
        sutToPerformFirstSave.save(firstMediaItems) { saveError in
            XCTAssertNil(saveError, "Expected to save media items successfully")
            saveExp1.fulfill()
        }
        wait(for: [saveExp1], timeout: 1.0)
        
        let saveExp2 = expectation(description: "Wait for save completion")
        sutToPerformSecondSave.save(lastMediaItems) { saveError in
            XCTAssertNil(saveError, "Expected to save media items successfully")
            saveExp2.fulfill()
        }
        wait(for: [saveExp2], timeout: 1.0)
        
        expect(sutToPerformLoad, toLoad: lastMediaItems)
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
    
    private func expect(_ sut: LocalMediaLoader, toLoad expectedItems: [MediaItem], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(mediaItems):
                XCTAssertEqual(mediaItems, expectedItems, "Expected empty array of items", file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successfull mediaItems result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
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
