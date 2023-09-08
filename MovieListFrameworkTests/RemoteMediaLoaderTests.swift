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
        
        sut.load { _ in }
         
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_delivers_ErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_delivers_ErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_delivers_NoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"results\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_delivers_ItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = MediaItem(adult: false,
                              backdropPath: "a backdrop path",
                              genreIds: [0,1,2],
                              id: UUID(),
                              mediaType: "movie",
                              originalLanguage: "a language",
                              originalTitle: "an original title",
                              overview: "an overview",
                              popularity: 3.0,
                              posterPath: "a poster path",
                              releaseDate: "a release date",
                              title: "a title",
                              video: false,
                              voteAverage: 2.0,
                              voteCount: 1)
        
        let item1JSON: [String: Any] = [
            "adult": item1.adult,
            "backdrop_path": item1.backdropPath,
            "genre_ids": item1.genreIds,
            "id": item1.id.uuidString,
            "media_type": item1.mediaType,
            "original_language": item1.originalLanguage,
            "original_title": item1.originalTitle,
            "overview": item1.overview,
            "popularity": item1.popularity,
            "poster_path": item1.posterPath,
            "release_date": item1.releaseDate,
            "title": item1.title,
            "video": item1.video,
            "vote_average": item1.voteAverage,
            "vote_count": item1.voteCount
        ]
        
        let item2 = MediaItem(adult: true,
                              backdropPath: nil,
                              genreIds: [],
                              id: UUID(),
                              mediaType: nil,
                              originalLanguage: "another language",
                              originalTitle: "another original title",
                              overview: "another overview",
                              popularity: 1.0,
                              posterPath: nil,
                              releaseDate: "another release date",
                              title: "another title",
                              video: true,
                              voteAverage: 4.3,
                              voteCount: 222)
        
        let item2JSON: [String: Any] = [
            "adult": item2.adult,
            "genre_ids": item2.genreIds,
            "id": item2.id.uuidString,
            "original_language": item2.originalLanguage,
            "original_title": item2.originalTitle,
            "overview": item2.overview,
            "popularity": item2.popularity,
            "release_date": item2.releaseDate,
            "title": item2.title,
            "video": item2.video,
            "vote_average": item2.voteAverage,
            "vote_count": item2.voteCount
        ]
        
        let itemsJSON = ["results": [item1JSON, item2JSON]]
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteMediaLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMediaLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteMediaLoader,
                        toCompleteWith result: RemoteMediaLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteMediaLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
        
    }
}
