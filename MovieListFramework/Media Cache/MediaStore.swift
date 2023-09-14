//
//  MediaStore.swift
//  MovieListFramework
//
//  Created by macbook on 13/09/2023.
//

import Foundation

public protocol MediaStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedMedia(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping (InsertionCompletion))
    func retrieve()
}
