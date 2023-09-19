//
//  RemoteMediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 06/09/2023.
//

import Foundation

public final class RemoteMediaLoader: MediaLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadMediaResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let data, let response):
                completion(RemoteMediaLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try MediaItemsMapper.map(data, response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteMediaItem {
    func toModels() -> [MediaItem] {
        return map { MediaItem(adult: $0.adult, backdropPath: $0.backdrop_path, genreIds: $0.genre_ids, id: $0.id, mediaType: $0.media_type, originalLanguage: $0.original_language, originalTitle: $0.original_title, overview: $0.overview, popularity: $0.popularity, posterPath: $0.poster_path, releaseDate: $0.release_date, title: $0.title, video: $0.video, voteAverage: $0.vote_average, voteCount: $0.vote_count) }
    }
}
