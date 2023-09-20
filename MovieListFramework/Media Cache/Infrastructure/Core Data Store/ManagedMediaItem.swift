//
//  ManagedMediaItem.swift
//  MovieListFramework
//
//  Created by macbook on 19/09/2023.
//

import CoreData

@objc(ManagedMediaItem)
internal class ManagedMediaItem: NSManagedObject {
    @NSManaged internal var adult: Bool
    @NSManaged internal var backdropPath: String?
    @NSManaged internal var genreIds: String?
    @NSManaged internal var id: Int64
    @NSManaged internal var mediaType: String?
    @NSManaged internal var originalLanguage: String
    @NSManaged internal var originalTitle: String
    @NSManaged internal var overview: String
    @NSManaged internal var popularity: Double
    @NSManaged internal var posterPath: String?
    @NSManaged internal var releaseDate: String
    @NSManaged internal var title: String
    @NSManaged internal var video: Bool
    @NSManaged internal var voteAverage: Double
    @NSManaged internal var voteCount: Int32
    @NSManaged internal var cache: ManagedCache
    
    internal var local: LocalMediaItem {
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
    
    internal static func cachedItems(from localMedia: [LocalMediaItem], in context: NSManagedObjectContext) -> NSOrderedSet {
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
