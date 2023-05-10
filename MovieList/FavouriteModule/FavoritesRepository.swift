//
//  FavoritesRepository.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func saveFavoriteMovie(_ movie: Movie)
    func removeFavoriteMovie(_ movie: Movie)
    func getFavoriteMovies() -> [Movie]
    func isMovieInFavorites(_ movie: Movie) -> Bool
}

class FavoritesRepository: FavoritesRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteMovies"
    
    func saveFavoriteMovie(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        favoriteMovies.append(movie)
        
        let encodedMovies = try? JSONEncoder().encode(favoriteMovies)
        userDefaults.set(encodedMovies, forKey: favoritesKey)
    }
    
    func removeFavoriteMovie(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        favoriteMovies.removeAll { $0.id == movie.id }
        
        let encodedMovies = try? JSONEncoder().encode(favoriteMovies)
        userDefaults.set(encodedMovies, forKey: favoritesKey)
    }
    
    func getFavoriteMovies() -> [Movie] {
        guard let encodedMovies = userDefaults.data(forKey: favoritesKey) else {
            return []
        }
        
        let favoriteMovies = try? JSONDecoder().decode([Movie].self, from: encodedMovies)
        return favoriteMovies ?? []
    }
    
    func isMovieInFavorites(_ movie: Movie) -> Bool {
        let favoriteMovies = getFavoriteMovies()
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }
}

