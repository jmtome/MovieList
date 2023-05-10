//
//  FavoritesInteractor.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesInteractorProtocol {
    func saveFavoriteMovie(_ movie: Movie)
    func removeFavorite(with movie: Movie)
    func getFavoriteMovies() -> [Movie]
}

class FavoritesInteractor: FavoritesInteractorProtocol {
    let favoritesRepository: FavoritesRepositoryProtocol
    weak var presenter: FavoritesPresenterProtocol?
    
    init(favoritesRepository: FavoritesRepositoryProtocol) {
        self.favoritesRepository = favoritesRepository
    }
    
    func saveFavoriteMovie(_ movie: Movie) {
        favoritesRepository.saveFavoriteMovie(movie)
        presenter?.favoriteMovieSaved()
    }
    
    func removeFavorite(with movie: Movie) {
        favoritesRepository.removeFavoriteMovie(movie)
        presenter?.favoriteMovieRemoved()
    }
    
    func getFavoriteMovies() -> [Movie] {
        return favoritesRepository.getFavoriteMovies()
    }
}
