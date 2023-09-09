//
//  MediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

public enum LoadMediaResult {
    case success([MediaItem])
    case failure(Error)
}

protocol MediaLoader {
    func load(completion: @escaping(LoadMediaResult) -> Void)
}
