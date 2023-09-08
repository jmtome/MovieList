//
//  RemoteMediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 06/09/2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteMediaLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([MediaItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                if response.statusCode == 200,
                   let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.results.map { $0.item }))
                } else {
                    completion(.failure(.invalidData))                    
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let results: [Item]
}

private struct Item: Decodable {
    let adult: Bool
    let backdrop_path: String?
    let genre_ids: [Int]
    let id: UUID
    let media_type: String?
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let release_date: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int

    var item: MediaItem {
        return MediaItem(adult: adult,
                         backdropPath: backdrop_path,
                         genreIds: genre_ids,
                         id: id,
                         mediaType: media_type,
                         originalLanguage: original_language,
                         originalTitle: original_title,
                         overview: overview,
                         popularity: popularity,
                         posterPath: poster_path,
                         releaseDate: release_date,
                         title: title,
                         video: video,
                         voteAverage: vote_average,
                         voteCount: vote_count)
    }
    
}
    
