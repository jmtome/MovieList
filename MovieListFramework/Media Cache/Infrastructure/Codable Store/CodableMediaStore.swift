//
//  CodableMediaStore.swift
//  MovieListFramework
//
//  Created by macbook on 16/09/2023.
//

import Foundation

public class CodableMediaStore: MediaStore {
    private struct Cache: Codable {
        let items: [CodableMediaItem]
        let timestamp: Date
        
        var localFeed: [LocalMediaItem] {
            return items.map { $0.local }
        }
    }
    
    private struct CodableMediaItem: Codable {
        private let adult: Bool
        private let backdropPath: String?
        private let genreIds: [Int]
        private let id: Int
        private let mediaType: String?
        private let originalLanguage: String
        private let originalTitle: String
        private let overview: String
        private let popularity: Double
        private let posterPath: String?
        private let releaseDate: String
        private let title: String
        private let video: Bool
        private let voteAverage: Double
        private let voteCount: Int
        
        init(_ media: LocalMediaItem) {
            adult = media.adult
            backdropPath = media.backdropPath
            genreIds = media.genreIds
            id = media.id
            mediaType = media.mediaType
            originalLanguage = media.originalLanguage
            originalTitle = media.originalTitle
            overview = media.overview
            popularity = media.popularity
            posterPath = media.posterPath
            releaseDate = media.releaseDate
            title = media.title
            video = media.video
            voteAverage = media.voteAverage
            voteCount = media.voteCount
        }
        
        var local: LocalMediaItem {
            return LocalMediaItem(adult: adult, backdropPath: backdropPath, genreIds: genreIds, id: id, mediaType: mediaType, originalLanguage: originalLanguage, originalTitle: originalTitle, overview: overview, popularity: popularity, posterPath: posterPath, releaseDate: releaseDate, title: title, video: video, voteAverage: voteAverage, voteCount: voteCount)
        }
    }
    
    private let queue = DispatchQueue(label: "\(CodableMediaStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func deleteCachedMedia(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ items: [LocalMediaItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(items: items.map(CodableMediaItem.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(.none))
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedItems(items: cache.localFeed, timestamp: cache.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
