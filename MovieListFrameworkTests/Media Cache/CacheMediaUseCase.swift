//
//  CacheMediaUseCase.swift
//  MovieListFramework
//
//  Created by macbook on 12/09/2023.
//

import XCTest

class LocalMediaLoader {
    init(store: MediaStore) {
        
    }
}

class MediaStore {
    var deleteCachedMediaCallCount = 0
}

class CacheMediaUseCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = MediaStore()
        _ = LocalMediaLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedMediaCallCount, 0)
    }
}
