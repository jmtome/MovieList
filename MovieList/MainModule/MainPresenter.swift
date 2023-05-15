//
//  MainPresenter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

protocol MainScreenPresenterProtocol: AnyObject {
    func didReceiveMovies(_ movies: [AnyMedia], with page: Int)
    func didEncounterError(_ error: Error)
    func didSelectMovie(_ movie: Movie)
    
    func handleFavoriteAction(for movie: AnyMedia)
    func isFavorite(movie: AnyMedia) -> Bool
    
    func viewDidLoad()
    func viewDidChangeSearchScope(_ scope: SearchScope)
    func viewDidChangeSearchQuery(_ query: String)
    func viewShouldFetchNewPage()
    
    func getSections() -> [Section]
    
    func isLoadingPage() -> Bool
}

class MainScreenPresenter: MainScreenPresenterProtocol {
    
  
    
    private var currentQuery: String = ""
    private var currentScope: SearchScope = .movies
    private var currentPage: Int = 1

    private var isLoading: Bool = false
    
    weak var view: MainScreenViewProtocol?
    var interactor: MainScreenInteractorProtocol?
    var router: MainScreenRouterProtocol?
    
    init(view: MainScreenViewProtocol, router: MainScreenRouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func viewDidLoad() {
        interactor?.getPopularMedia(currentScope: currentScope, page: currentPage)
    }
    
    func isLoadingPage() -> Bool {
        self.isLoading
    }
    
    func getSections() -> [Section] {
        switch currentScope {
        case .movies:
            return currentQuery.isEmpty ? [.popularMovies] : [.movies]
        case .series:
            return currentQuery.isEmpty ? [.popularShows] : [.tvshows]
        default: return [.movies]
        }
    }
    
    func viewShouldFetchNewPage() {
        currentPage += 1
        
        self.isLoading = true
        
        guard !currentQuery.isEmpty else { interactor?.getPopularMedia(currentScope: currentScope, page: currentPage) ; return }
        interactor?.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
//    func loadSearch(for query: String, scope: SearchScope, page: Int) {
//        currentQuery = query
//        currentScope = scope
//        currentPage = page
//        guard !currentQuery.isEmpty else { interactor?.getPopularMedia(currentScope: currentScope, page: currentPage) ; return  }
//        interactor?.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
//    }
    
    func viewDidChangeSearchQuery(_ query: String) {
        currentQuery = query
        currentPage = 1
        
        self.isLoading = true
        
        guard !currentQuery.isEmpty else { interactor?.getPopularMedia(currentScope: currentScope, page: currentPage) ; return }
        interactor?.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
    func viewDidChangeSearchScope(_ scope: SearchScope) {
        currentScope = scope
        currentPage = 1
        
        self.isLoading = true
        
        interactor?.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
    func didReceiveMovies(_ movies: [AnyMedia], with page: Int) {
        self.isLoading = false
        view?.displayMovies(movies, for: page)
    }
    
    func didEncounterError(_ error: Error) {
        self.isLoading = false
        view?.displayError(error.localizedDescription)
    }
    
    func didSelectMovie(_ movie: Movie) {
        router?.navigateToDetailScreen(with: movie)
    }
    
    func handleFavoriteAction(for movie: AnyMedia) {
        if isFavorite(movie: movie) {
            interactor?.removeFavorite(with: movie)
            view?.didRemoveMovieFromFavorites(movie: movie)
        } else {
            interactor?.saveFavorite(with: movie)
            view?.didAddMovieToFavorites(movie: movie)
        }
    }
    
    func isFavorite(movie: AnyMedia) -> Bool {
        return interactor?.isMovieInFavorites(movie: movie) ?? false
    }
    
}
