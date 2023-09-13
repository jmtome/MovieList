//
//  LocalMediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 13/09/2023.
//

import Foundation

public final class LocalMediaLoader {
    private let store: MediaStore
    private let currentDate: () -> Date
    
    public init(store: MediaStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [MediaItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedMedia { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [MediaItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

public protocol MediaStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedMedia(completion: @escaping DeletionCompletion)
    func insert(_ items: [MediaItem], timestamp: Date, completion: @escaping (InsertionCompletion))
}
