//
//  FavoritesRepository.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func isMediaInFavorites(media: MediaViewModel) -> Bool
    func saveFavorite(media: MediaViewModel)
    func removeFavorite(media: MediaViewModel)
    func getFavoriteMedia(for type: MediaType) -> [MediaViewModel]
}

final class FavoritesRepository {
    private let userDefaults = UserDefaults.standard
    private let favoriteMoviesKey = "FavoriteMovies"
    private let favoriteShowsKey = "FavoriteShows"
    
}

//MARK: - FavoritesRepositoryProtocol Conformance
extension FavoritesRepository: FavoritesRepositoryProtocol {
    func isMediaInFavorites(media: MediaViewModel) -> Bool {
        getFavoriteMedia(for: media.type).contains { $0.id == media.id }
    }
    
    func saveFavorite(media: MediaViewModel) {
        var favoriteMedia = getFavoriteMedia(for: media.type)
        favoriteMedia.append(media)
        
        let encodedMedia = try? JSONEncoder().encode(favoriteMedia)
        userDefaults.set(encodedMedia, forKey: media.type == .movie ? favoriteMoviesKey : favoriteShowsKey)
    }

    func removeFavorite(media: MediaViewModel) {
        var favoriteMedia = getFavoriteMedia(for: media.type)
        favoriteMedia.removeAll { $0.id == media.id }
        
        let encodedMedia = try? JSONEncoder().encode(favoriteMedia)
        userDefaults.set(encodedMedia, forKey: media.type == .movie ? favoriteMoviesKey : favoriteShowsKey)
    }
    
    func getFavoriteMedia(for type: MediaType) -> [MediaViewModel] {
        guard let encodedMedia = userDefaults.data(forKey: type == .movie ? favoriteMoviesKey : favoriteShowsKey) else {
            return []
        }
        
        let favoriteMedia = try? JSONDecoder().decode([MediaViewModel].self, from: encodedMedia)
        return favoriteMedia ?? []
    }
}

