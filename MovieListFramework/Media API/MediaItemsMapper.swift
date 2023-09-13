//
//  MediaItemsMapper.swift
//  MovieListFramework
//
//  Created by macbook on 08/09/2023.
//

import Foundation

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

    
