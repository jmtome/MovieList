//
//  RemoteMediaLoaderTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 05/09/2023.
//

import XCTest

class RemoteMediaLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}

final class RemoteMediaLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteMediaLoader(client: client)
    
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteMediaLoader(client: client)
        
        sut.load()
         
        XCTAssertNotNil(client.requestedURL)
    }

}
