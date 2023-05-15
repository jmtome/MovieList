//
//  FavoritesRepository.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func saveFavoriteMovie(_ movie: Movie)
    func saveFavoriteShow(_ show: TVShow)
    
    func removeFavoriteMovie(_ movie: Movie)
    func removeFavoriteShow(_ show: TVShow)
    
    func getFavoriteMovies() -> [Movie]
    func getFavoriteShows() -> [TVShow]
    
    func isMovieInFavorites(_ movie: Movie) -> Bool
    func isTvShowInFavorites(_ tvshow: TVShow) -> Bool
}

class FavoritesRepository: FavoritesRepositoryProtocol {
    
    
    private let userDefaults = UserDefaults.standard
    private let favoriteMoviesKey = "FavoriteMovies"
    private let favoriteShowsKey = "FavoriteShows"
    
    func saveFavoriteMovie(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        favoriteMovies.append(movie)
        
        let encodedMovies = try? JSONEncoder().encode(favoriteMovies)
        userDefaults.set(encodedMovies, forKey: favoriteMoviesKey)
    }
    
    func saveFavoriteShow(_ show: TVShow) {
        var favoriteShows = getFavoriteShows()
        favoriteShows.append(show)
        
        let encodedShows = try? JSONEncoder().encode(favoriteShows)
        userDefaults.set(encodedShows, forKey: favoriteShowsKey)
    }
    
    func removeFavoriteMovie(_ movie: Movie) {
        var favoriteMovies = getFavoriteMovies()
        favoriteMovies.removeAll { $0.id == movie.id }
        
        let encodedMovies = try? JSONEncoder().encode(favoriteMovies)
        userDefaults.set(encodedMovies, forKey: favoriteMoviesKey)
    }
    
    func removeFavoriteShow(_ show: TVShow) {
        var favoriteShows = getFavoriteShows()
        favoriteShows.removeAll { $0.id == show.id }
        
        let encodedShows = try? JSONEncoder().encode(favoriteShows)
        userDefaults.set(encodedShows, forKey: favoriteShowsKey)
    }
    
    func getFavoriteMovies() -> [Movie] {
        guard let encodedMovies = userDefaults.data(forKey: favoriteMoviesKey) else {
            return []
        }
        
        let favoriteMovies = try? JSONDecoder().decode([Movie].self, from: encodedMovies)
        return favoriteMovies ?? []
    }
    
    func getFavoriteShows() -> [TVShow] {
        guard let encodedShows = userDefaults.data(forKey: favoriteShowsKey) else {
            return []
        }
        
        let favoriteShows = try? JSONDecoder().decode([TVShow].self, from: encodedShows)
        return favoriteShows ?? []
    }
    
    func isMovieInFavorites(_ movie: Movie) -> Bool {
        let favoriteMovies = getFavoriteMovies()
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }
    
    func isTvShowInFavorites(_ tvshow: TVShow) -> Bool {
        let favoriteMovies = getFavoriteShows()
        return favoriteMovies.contains(where: { $0.id == tvshow.id })
    }
}

