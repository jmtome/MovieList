//
//  CoreDataMediaStore.swift
//  MovieListFramework
//
//  Created by macbook on 18/09/2023.
//

import Foundation
import CoreData

public final class CoreDataMediaStore: MediaStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "MediaStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedMedia(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.items = NSOrderedSet(array: items.map({ local in
                    let managedItem = ManagedMediaItem(context: context)
                    managedItem.adult = local.adult
                    managedItem.backdropPath = local.backdropPath
                    managedItem.genreIds = CoreDataMediaStore.encodeIntArrayToJson(local.genreIds)
                    managedItem.id = Int64(local.id)
                    managedItem.mediaType = local.mediaType
                    managedItem.originalLanguage = local.originalLanguage
                    managedItem.originalTitle = local.originalTitle
                    managedItem.overview = local.overview
                    managedItem.popularity = local.popularity
                    managedItem.posterPath = local.posterPath
                    managedItem.releaseDate = local.releaseDate
                    managedItem.title = local.title
                    managedItem.video = local.video
                    managedItem.voteAverage = local.voteAverage
                    managedItem.voteCount = Int32(local.voteCount)
                    return managedItem
                }))
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                
                guard let cache = try context.fetch(request).first else {
                    return completion(.empty)
                }
                
                let retrievedItems = cache.items.compactMap { $0 as? ManagedMediaItem }.map { CoreDataMediaStore.mapToLocal($0) }
                let retrievedTimestamp = cache.timestamp
                
                completion(.found(items: retrievedItems, timestamp: retrievedTimestamp))
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func mapToLocal(_ managedItem: ManagedMediaItem) -> LocalMediaItem {
        LocalMediaItem(adult: managedItem.adult, backdropPath: managedItem.backdropPath, genreIds: decodeJsonToIntArray(managedItem.genreIds), id: Int(managedItem.id), mediaType: managedItem.mediaType, originalLanguage: managedItem.originalLanguage, originalTitle: managedItem.originalTitle, overview: managedItem.overview, popularity: managedItem.popularity, posterPath: managedItem.posterPath, releaseDate: managedItem.releaseDate, title: managedItem.title, video: managedItem.video, voteAverage: managedItem.voteAverage, voteCount: Int(managedItem.voteCount))
    }
    
    private static func encodeIntArrayToJson(_ array: [Int]) -> String? {
        let jsonEncoder = JSONEncoder()
        if let jsonData = try? jsonEncoder.encode(array),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
    private static func decodeJsonToIntArray(_ jsonString: String?) -> [Int] {
        guard let jString = jsonString else { return [] }
        if let jsonData = jString.data(using: .utf8),
           let intArray = try? JSONDecoder().decode([Int].self, from: jsonData) {
            return intArray
        }
        return []
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged public var timestamp: Date
    @NSManaged public var items: NSOrderedSet
}

@objc(ManagedMediaItem)
private class ManagedMediaItem: NSManagedObject {
    @NSManaged public var adult: Bool
    @NSManaged public var backdropPath: String?
    @NSManaged public var genreIds: String?
    @NSManaged public var id: Int64
    @NSManaged public var mediaType: String?
    @NSManaged public var originalLanguage: String
    @NSManaged public var originalTitle: String
    @NSManaged public var overview: String
    @NSManaged public var popularity: Double
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String
    @NSManaged public var title: String
    @NSManaged public var video: Bool
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int32
    @NSManaged public var cache: ManagedCache
}
