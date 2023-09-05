//
//  MovieItem.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

typealias MediaItem = MovieItem

struct MovieItem {
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
}


