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
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
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
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_delivers_ItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(adult: false,
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
        
        
        let item2 = makeItem(adult: true,
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
    
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #file, line: UInt = #line) -> (sut: RemoteMediaLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteMediaLoader(url: url, client: client)
       
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func makeItem(adult: Bool, backdropPath: String? = nil, genreIds: [Int], id: UUID, mediaType: String? = nil, originalLanguage: String, originalTitle: String, overview: String, popularity: Double, posterPath: String? = nil, releaseDate: String, title: String, video: Bool, voteAverage: Double, voteCount: Int) -> (model: MediaItem, json: [String: Any]) {
        let item = MediaItem(adult: adult,
                             backdropPath: backdropPath,
                             genreIds: genreIds,
                             id: id,
                             mediaType: mediaType,
                             originalLanguage: originalLanguage,
                             originalTitle: originalTitle,
                             overview: overview,
                             popularity: popularity,
                             posterPath: posterPath,
                             releaseDate: releaseDate,
                             title: title,
                             video: video,
                             voteAverage: voteAverage,
                             voteCount: voteCount)
        
        let json = [
            "adult": item.adult,
            "backdrop_path": item.backdropPath,
            "genre_ids": item.genreIds,
            "id": item.id.uuidString,
            "media_type": item.mediaType,
            "original_language": item.originalLanguage,
            "original_title": item.originalTitle,
            "overview": item.overview,
            "popularity": item.popularity,
            "poster_path": item.posterPath,
            "release_date": item.releaseDate,
            "title": item.title,
            "video": item.video,
            "vote_average": item.voteAverage,
            "vote_count": item.voteCount
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
        return try! JSONSerialization.data(withJSONObject: json)
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
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
        
    }
}
