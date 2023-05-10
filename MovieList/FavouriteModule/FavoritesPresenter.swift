//
//  FavoritesPresenter.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import Foundation

protocol FavoritesPresenterProtocol: AnyObject {
    func favoriteMovieSaved()
    func favoriteMovieRemoved()
    func removeFavoriteMovie(_ movie: Movie) 
    func getFavoriteMovies()
}

class FavoritesPresenter: FavoritesPresenterProtocol {
    weak var view: FavoritesViewProtocol?
    private let interactor: FavoritesInteractorProtocol
    
    init(interactor: FavoritesInteractorProtocol) {
        self.interactor = interactor
    }
    
    func favoriteMovieSaved() {
        // Handle favorite movie saved event
    }
    
    func favoriteMovieRemoved() {
        // Handle favorite movie removed event
    }
    
    func getFavoriteMovies() {
        let favoriteMovies = interactor.getFavoriteMovies()
        view?.displayFavorites(favoriteMovies)
    }
    
    func saveFavoriteMovie(_ movie: Movie) {
        interactor.saveFavoriteMovie(movie)
    }
    
    func removeFavoriteMovie(_ movie: Movie) {
        interactor.removeFavorite(with: movie)
//        view?.didRemoveMovieFromFavorites(movie: movie)
        getFavoriteMovies()
    }
}

