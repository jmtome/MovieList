//
//  CoreDataMediaStore.swift
//  MovieListFramework
//
//  Created by macbook on 18/09/2023.
//

import Foundation
import CoreData

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

private class ManagedCache: NSManagedObject {
    @NSManaged public var timestamp: Date?
    @NSManaged public var items: NSOrderedSet
}

private class ManagedMediaItem: NSManagedObject {
    @NSManaged public var adult: Bool
    @NSManaged public var backdropPath: String?
    @NSManaged public var genreIds: String?
    @NSManaged public var id: Int32
    @NSManaged public var mediaType: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var overview: String?
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int32
    @NSManaged public var cache: ManagedCache
}
