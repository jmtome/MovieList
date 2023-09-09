//
//  MediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

public enum LoadMediaResult<Error: Swift.Error> {
    case success([MediaItem])
    case failure(Error)
}

extension LoadMediaResult: Equatable where Error: Equatable {}

protocol MediaLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping(LoadMediaResult<Error>) -> Void)
}
