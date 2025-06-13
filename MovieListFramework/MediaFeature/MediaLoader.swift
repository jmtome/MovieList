//
//  MediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 05/09/2023.
//

import Foundation


public protocol MediaLoader {
    typealias Result = Swift.Result<[MediaItem], Error>
    func load(completion: @escaping(Result) -> Void)
}
