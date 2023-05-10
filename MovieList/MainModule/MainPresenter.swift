//
//  MainPresenter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

protocol MainScreenPresenterProtocol: AnyObject {
    func didReceiveMovies(_ movies: [Movie])
    func didEncounterError(_ error: Error)
    func didSelectMovie(_ movie: Movie)
    
    func handleFavoriteAction(for movie: Movie)
    func isFavorite(movie: Movie) -> Bool
    
    func viewDidLoad()
    func viewDidChangeSearchScope(_ scope: SearchScope)
    func viewDidChangeSearchQuery(_ query: String)
}

class MainScreenPresenter: MainScreenPresenterProtocol {
    
  
    
    private var currentQuery: String = ""
    private var currentScope: SearchScope = .movies
    weak var view: MainScreenViewProtocol?
    var interactor: MainScreenInteractorProtocol?
    var router: MainScreenRouterProtocol?
    
    init(view: MainScreenViewProtocol, router: MainScreenRouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func viewDidLoad() {
        interactor?.getPopularMovies()
    }
    
    func viewDidChangeSearchQuery(_ query: String) {
        currentQuery = query
        guard !query.isEmpty else { interactor?.getPopularMovies() ; return }
        interactor?.searchMovies(with: currentQuery, scope: currentScope)
    }
    
    func viewDidChangeSearchScope(_ scope: SearchScope) {
        currentScope = scope
        interactor?.searchMovies(with: currentQuery, scope: currentScope)
    }
    
    func didReceiveMovies(_ movies: [Movie]) {
        view?.displayMovies(movies)
    }
    
    func didEncounterError(_ error: Error) {
        view?.displayError(error.localizedDescription)
    }
    
    func didSelectMovie(_ movie: Movie) {
        router?.navigateToDetailScreen(with: movie)
    }
    
    func handleFavoriteAction(for movie: Movie) {
        if isFavorite(movie: movie) {
            interactor?.removeFavorite(with: movie)
            view?.didRemoveMovieFromFavorites(movie: movie)
        } else {
            interactor?.saveFavorite(with: movie)
            view?.didAddMovieToFavorites(movie: movie)
        }
    }
    
    func isFavorite(movie: Movie) -> Bool {
        return interactor?.isMovieInFavorites(movie: movie) ?? false
    }
    
}
