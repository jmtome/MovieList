//
//  MediaItemsMapper.swift
//  MovieListFramework
//
//  Created by macbook on 08/09/2023.
//

import Foundation

internal struct RemoteMediaItem: Decodable {
    internal let adult: Bool
    internal let backdrop_path: String?
    internal let genre_ids: [Int]
    internal let id: Int
    internal let media_type: String?
    internal let original_language: String
    internal let original_title: String
    internal let overview: String
    internal let popularity: Double
    internal let poster_path: String?
    internal let release_date: String
    internal let title: String
    internal let video: Bool
    internal let vote_average: Double
    internal let vote_count: Int
}

internal class MediaItemsMapper {
    private struct Root: Decodable {
        let results: [RemoteMediaItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteMediaItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteMediaLoader.Error.invalidData
        }
        
        return root.results
    }
    
}

    
