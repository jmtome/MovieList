//
//  MediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation

public typealias LoadMediaResult = Result<[MediaItem], Error>

public protocol MediaLoader {
    func load(completion: @escaping(LoadMediaResult) -> Void)
}
