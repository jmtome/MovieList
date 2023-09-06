//
//  RemoteMediaLoaderTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 05/09/2023.
//

import XCTest

class RemoteMediaLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteMediaLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteMediaLoader()
    
        XCTAssertNil(client.requestedURL)
    }

}
