//
//  FavoritesInteractor.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesInteractorProtocol {
    func saveFavoriteMovie(_ movie: Movie)
    func removeFavorite(with movie: AnyMedia)
    
    func getFavoriteMovies() -> [Movie]
    func getFavoriteShows() -> [TVShow]
    
    func getFavoriteMedia() -> [AnyMedia]
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
    
    
    func removeFavorite(with movie: AnyMedia) {
        if let film = movie.getBaseType() as? Movie {
            favoritesRepository.removeFavoriteMovie(film)
        }
        if let show = movie.getBaseType() as? TVShow {
            favoritesRepository.removeFavoriteShow(show)
        }
    }
    
    func getFavoriteMovies() -> [Movie] {
        return favoritesRepository.getFavoriteMovies()
    }
    func getFavoriteShows() -> [TVShow] {
        return favoritesRepository.getFavoriteShows()
    }
    
    func getFavoriteMedia() -> [AnyMedia] {
        return getFavoriteMovies().map { AnyMedia($0) } + getFavoriteShows().map { AnyMedia($0) }
    }
}
