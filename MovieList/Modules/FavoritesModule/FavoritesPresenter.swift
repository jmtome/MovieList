//
//  FavoritesPresenter.swift
//  MovieList
//
//  Created by macbook on 23/05/2023.
//

import Foundation


final class FavoritesScreenPresenter {
    private var currentQuery: String = ""

    // State variables related to the sorting of the table
    private var _sortOption = SortingOption.relevance
    private var _isAscending = false

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
    func isFavorite(viewModel: MediaViewModel) -> Bool {
        interactor.isMovieInFavorites(media: viewModel)
    }
    
    func handleFavoriteAction(viewModel: MediaViewModel) {
        interactor.handleFavoriteAction(with: viewModel)
    }
    
    var title: String {
        return "Favorite Media"
    }
    
    var searchBarTitle: String {
        return "Search Favorite \(currentScope.displayTitle.capitalized)"
    }
    
    var mediaCount: Int {
        viewModel.count
    }
    
    var sortOption: SortingOption {
        get {
            _sortOption
        }
        set {
            _sortOption = newValue
        }
    }
    
    var isAscending: Bool {
        get {
            _isAscending
        }
        set {
            _isAscending = newValue
        }
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
    
    //This code is duplicated in the MainPresenter, see a way to refactor this
    func sortMedia(with option: SortingOption) {
        switch sortOption {
        case .relevance:
            viewModel.sort { isAscending ? ($0.popularity > $1.popularity) : ($0.popularity < $1.popularity) }
        case .date:
            viewModel.sort { isAscending ? ($0.dateAired > $1.dateAired) : ($0.dateAired < $1.dateAired) }
        case .rating:
            viewModel.sort { isAscending ? ($0.rating > $1.rating) : ($0.rating < $1.rating) }
        case .title:
            viewModel.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == (isAscending ? .orderedAscending : .orderedDescending) }
        }
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
