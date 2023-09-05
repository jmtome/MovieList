//
//  MediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

enum LoadMediaResult {
    case success([MediaItem])
}

protocol MediaLoader {
    func load(completion: @escaping(LoadMediaResult) -> Void)
}
