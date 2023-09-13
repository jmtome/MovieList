//
//  RemoteMediaItem.swift
//  MovieListFramework
//
//  Created by macbook on 13/09/2023.
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
