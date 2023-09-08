//
//  MediaItemsMapper.swift
//  MovieListFramework
//
//  Created by macbook on 08/09/2023.
//

import Foundation

internal class MediaItemsMapper {
    private struct Root: Decodable {
        let results: [Item]
        
        var media: [MediaItem] {
            return results.map { $0.item }
        }
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteMediaLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)  else {
            return .failure(.invalidData)
        }
        
        return .success(root.media)
    }
    
}

    
