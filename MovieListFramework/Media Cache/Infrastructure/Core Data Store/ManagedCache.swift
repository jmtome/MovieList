//
//  ManagedCache.swift
//  MovieListFramework
//
//  Created by macbook on 19/09/2023.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged internal var timestamp: Date
    @NSManaged internal var items: NSOrderedSet
    
    internal var localItems: [LocalMediaItem] {
        return items.compactMap { ($0 as? ManagedMediaItem)?.local }
    }
    
    internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}
