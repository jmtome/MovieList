//
//  CoreDataMediaStore.swift
//  MovieListFramework
//
//  Created by macbook on 18/09/2023.
//

import Foundation

public final class CoreDataMediaStore: MediaStore {
    public init() {}
    
    public func deleteCachedMedia(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
