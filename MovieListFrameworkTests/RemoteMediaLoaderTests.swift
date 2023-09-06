//
//  RemoteMediaLoaderTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 05/09/2023.
//

import XCTest

class RemoteMediaLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    var requestedURL: URL?
}

final class RemoteMediaLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteMediaLoader()
    
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteMediaLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
