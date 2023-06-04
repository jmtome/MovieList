//
//  FavoritesPresenter.swift
//  MovieList
//
//  Created by macbook on 23/05/2023.
//

import Foundation


final class FavoritesScreenPresenter {
    private var currentQuery: String = ""
    
    //MARK: - Refactor this so that SearchScope and MediaType are only one type.
    private var currentScope: SearchScope = .movies {
        didSet {
            currentMediaType = currentScope == .movies ? .movie : .tvshow
        }
    }
    private var currentMediaType: MediaType = .movie
    
    //output of the presenter, which in this case would be the view
    weak var output: MainScreenPresenterOutputProtocol?
    
    var interactor: FavoritesScreenInteractorInputProtocol!
    var router: MainScreenRouterProtocol!
    
    init(interactor: FavoritesScreenInteractorInputProtocol, router: MainScreenRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    private var viewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUIList()
        }
    }
}

extension FavoritesScreenPresenter: MainScreenPresenterInputProtocol {
    var title: String {
        return "Favorite Media"
    }
    
    var searchBarTitle: String {
        return "Search Favorite \(currentScope.displayTitle.capitalized)"
    }
    
    var mediaCount: Int {
        viewModel.count
    }
    
    func viewDidLoad() {
        interactor.getFavoriteMedia(for: currentMediaType)
    }
    
    func viewWillAppear() {
        interactor.getFavoriteMedia(for: currentMediaType, matching: currentQuery)
    }
    
    func getMedia() -> [MediaViewModel] {
        viewModel
    }
    
    func getSections() -> [Section] {
        switch currentScope {
        case .movies:
            return [.favoritesMovies]
        case .series:
            return [.favoriteShows]
        }
    }
    
    func sortMedia(with option: SortingOption) {
        
    }
    
    func isFavorite(at index: Int) -> Bool {
        return interactor.isMovieInFavorites(media: viewModel[index])
    }
    
    func handleFavoriteAction(at index: Int) {
        interactor.handleFavoriteAction(with: viewModel[index])
    }
    
    func didSelectCell(at index: Int) {
        router.navigateToDetailScreen(with: viewModel[index])
    }
    
    func updateSearchResults(with query: String, scope: SearchScope) {
        guard !(query == currentQuery && scope == currentScope) else { return }
        self.currentQuery = query
        self.currentScope = scope
        
        interactor.getFavoriteMedia(for: currentMediaType, matching: currentQuery)
    }
}

extension FavoritesScreenPresenter: FavoritesScreenInteractorOutputProtocol {
    func presentMediaRemovedFromFavorites() {
        interactor.getFavoriteMedia(for: currentMediaType)
        output?.showAlertUnfavoritedMedia()
    }
    
    func didReceiveFavoriteMedia(_ media: [MediaViewModel]) {
        self.viewModel = media
    }
    
}
