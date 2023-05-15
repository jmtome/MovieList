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
    func removeFavoriteMovie(_ movie: AnyMedia)
    func getFavoriteMedia()
    
    func getFavoriteShows()
    func getFavoriteMovies()
    
    func viewDidChangeSearchQuery(_ query: String)
    func viewDidChangeSearchScope(_ scope: SearchScope)
}

class FavoritesPresenter: FavoritesPresenterProtocol {
      
    weak var view: FavoritesViewProtocol?
    private let interactor: FavoritesInteractorProtocol
    private var favShows: [TVShow] = []
    private var favMovies: [Movie] = []
    private var searchScope: SearchScope = .movies
    private var searchQuery: String = ""
    
    init(interactor: FavoritesInteractorProtocol) {
        self.interactor = interactor
    }
    
    func favoriteMovieSaved() {
        // Handle favorite movie saved event
    }
    
    func favoriteMovieRemoved() {
        // Handle favorite movie removed event
    }
    
    func getFavoriteMedia() {
        let favoriteMedia = interactor.getFavoriteMedia()
        view?.displayFavoriteMedia(favoriteMedia)
    }
    
    func viewDidChangeSearchScope(_ scope: SearchScope) {
        self.searchScope = scope
        switch scope {
        case .movies:
            let favoriteMovies = interactor.getFavoriteMovies()
            if favoriteMovies.isEmpty {
                view?.displayFavoriteMedia([AnyMedia(Movie())])
            } else {
                view?.displayFavoriteMedia(favoriteMovies.map { AnyMedia($0) })
            }
        case .series:
            let favoriteShows = interactor.getFavoriteShows()
            if favoriteShows.isEmpty {
                view?.displayFavoriteMedia([AnyMedia(TVShow())])
            } else {
                view?.displayFavoriteMedia(favoriteShows.map { AnyMedia($0) })                
            }
        default: getFavoriteMedia()
        }
    }
    // refactor this i dont like it
    func viewDidChangeSearchQuery(_ query: String) {
        self.searchQuery = query
        guard !query.isEmpty else { viewDidChangeSearchScope(searchScope) ; return }
        switch searchScope {
        case .movies:
            let favMovs = interactor.getFavoriteMovies().map { AnyMedia($0) }.filter { $0.title.contains(query) }
            view?.displayFavoriteMedia(favMovs)
        case .series:
            let favShows = interactor.getFavoriteShows().map { AnyMedia($0) }.filter { $0.title.contains(query) }
            view?.displayFavoriteMedia(favShows)
        default:
            view?.displayFavoriteMedia([])
        }
    }
    
    
    func getFavoriteShows() {
    }
    
    func getFavoriteMovies() {
        
    }
    
    func saveFavoriteMovie(_ movie: Movie) {
        interactor.saveFavoriteMovie(movie)
    }
    
    func removeFavoriteMovie(_ movie: AnyMedia) {
        interactor.removeFavorite(with: movie)
        viewDidChangeSearchScope(self.searchScope)
    }
}

