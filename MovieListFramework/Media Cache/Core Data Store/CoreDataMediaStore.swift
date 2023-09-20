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
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.items = ManagedMediaItem.cachedItems(from: items, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                guard let cache = try ManagedCache.find(in: context) else {
                    return completion(.empty)
                }
                
                completion(.found(items: cache.localItems, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
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
    
    var localItems: [LocalMediaItem] {
        return items.compactMap { ($0 as? ManagedMediaItem)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
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
    
    var local: LocalMediaItem {
        LocalMediaItem(adult: adult,
                       backdropPath: backdropPath,
                       genreIds: genreIds.mapJSONToArray(of: Int.self),
                       id: Int(id),
                       mediaType: mediaType,
                       originalLanguage: originalLanguage,
                       originalTitle: originalTitle,
                       overview: overview,
                       popularity: popularity,
                       posterPath: posterPath,
                       releaseDate: releaseDate,
                       title: title,
                       video: video,
                       voteAverage: voteAverage,
                       voteCount: Int(voteCount))
    }
    
    static func cachedItems(from localMedia: [LocalMediaItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        NSOrderedSet(array: localMedia.map({ local in
            let managedItem = ManagedMediaItem(context: context)
            managedItem.adult = local.adult
            managedItem.backdropPath = local.backdropPath
            managedItem.genreIds = local.genreIds.mapToJSONString()
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
    }
}

private extension Array where Element: Encodable {
    func mapToJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

private extension String? {
    func mapJSONToArray<T: Decodable>(of type: T.Type) -> [T] {
        guard let data = self?.data(using: .utf8),
              let array = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return array
    }
}

