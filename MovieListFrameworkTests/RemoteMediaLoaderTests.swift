//
//  RemoteMediaLoaderTests.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 05/09/2023.
//

import XCTest
import MovieListFramework

final class RemoteMediaLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
    
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
         
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        // Given
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        var capturedError: RemoteMediaLoader.Error?
        
        // When
        sut.load { error in
            capturedError = error
        }
        
        // Then
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteMediaLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMediaLoader(url: url, client: client)
        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
        
    }
}
