//
//  MainPresenter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

//MARK: - MainScreen Presenter Output Protocol
//Called by Presenter, Implemented by MainScreenViewController
protocol MainScreenPresenterOutputProtocol: AnyObject {
    func updateUIList()
    
    func updateUINowPlaying()
    func updateUIPopular()
    func updateUIUpcoming()
    func updateUITopRated()
    func updateUITrending()

    func showError(_ error: Error)
    func showAlertFavoritedMedia()
    func showAlertUnfavoritedMedia()
}

//MARK: - MainScreen Presenter Input Protocol
//Called by MainScreenViewController, Implemented by Presenter
protocol MainScreenPresenterInputProtocol: AnyObject {
    var title: String { get }
    var searchBarTitle: String { get }
    var mediaCount: Int { get }
    
    var sortOption: SortingOption { get set }
    var isAscending: Bool { get set }
    
    func viewDidLoad()
    func viewWillAppear()
    
    func getMedia(_ category: MediaCategory) -> [MediaViewModel]
    func getSections() -> [Section]
    
    func sortMedia(with option: SortingOption)
    
    func isFavorite(at index: Int) -> Bool
    func isFavorite(viewModel: MediaViewModel) -> Bool
    func handleFavoriteAction(at index: Int)
    func handleFavoriteAction(viewModel: MediaViewModel)
    
    func didSelectCell(at index: Int)
    
    func updateSearchResults(with query: String, scope: SearchScope)
    
    //
    func fetchAllCategories(_ scope: SearchScope)
    func fetchNowPlayingMedia()
    func fetchpopularMedia()
    func fetchUpcomingMedia()
    func fetchTopRatedMedia()
    func fetchtrendingsMedia()
}

protocol MainScreenPresenterLoadingInputProtocol: AnyObject {
    func isLoadingPage() -> Bool
    func viewShouldFetchNewPage()
}

//MARK: - MainScreenPresenter
class MainScreenPresenter {
    private var currentQuery: String = ""
    private var currentScope: SearchScope = .series
    private var currentPage: Int = 1
    private var isLoading: Bool = false

    // State variables related to the sorting of the table
    private var _sortOption = SortingOption.relevance
    private var _isAscending = true

    //output of the presenter, which in this case would be the view
    weak var output: MainScreenPresenterOutputProtocol?
    
    var interactor: MainScreenInteractorProtocol!
    var router: MainScreenRouterProtocol!
    
    init(interactor: MainScreenInteractorProtocol, router: MainScreenRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    private var viewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUIList()
        }
    }
    
    private var nowPlayingViewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUINowPlaying()
        }
    }
    
    private var popularMediaViewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUIPopular()
        }
    }
    
    private var upcomingMediaViewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUIUpcoming()
        }
    }
    
    private var topRatedMediaViewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUITopRated()
        }
    }
    
    private var trendingMediaViewModel: [MediaViewModel] = [] {
        didSet {
            output?.updateUITrending()
        }
    }
}

extension MainScreenPresenter {
    func fetchAllCategories(_ scope: SearchScope) {
        guard currentScope != scope else { return }
        currentScope = scope
        // Launch all the interactor calls concurrently without waiting
        Task {
            interactor.getNowPlayingMedia(scope: currentScope, page: currentPage)
            interactor.getPopularMedia(scope: currentScope, page: currentPage)
            interactor.getUpcomingMedia(scope: currentScope, page: currentPage)
            interactor.getTrendingMedia(scope: currentScope, page: currentPage)
            interactor.getTopRatedMedia(scope: currentScope, page: currentPage)
            viewDidLoad()
        }
    }
    func fetchNowPlayingMedia() {
        guard !isLoading else { print( "#### cant fetch now playing media, already fetching"); return }
        isLoading = true
        interactor.getNowPlayingMedia(scope: currentScope, page: currentPage)
    }
    func fetchpopularMedia() {
        guard !isLoading else { print( "#### cant fetch popular media, already fetching"); return }
        isLoading = true
        interactor.getPopularMedia(scope: currentScope, page: currentPage)
    }
    func fetchUpcomingMedia() {
        guard !isLoading else { print( "#### cant fetch upcoming media, already fetching"); return }
        isLoading = true
        interactor.getUpcomingMedia(scope: currentScope, page: currentPage)
    }
    func fetchTopRatedMedia() {
        guard !isLoading else { print( "#### cant fetch top rated media, already fetching"); return }
        isLoading = true
        interactor.getTopRatedMedia(scope: currentScope, page: currentPage)
    }
    func fetchtrendingsMedia() {
        guard !isLoading else { print( "#### cant fetch trending media, already fetching"); return }
        isLoading = true
        interactor.getTrendingMedia(scope: currentScope, page: currentPage)
    }
}

//MARK: - MainScreenPresenterInputProtocol Connformance
// Called by the View, implemented by the Presenter
extension MainScreenPresenter: MainScreenPresenterInputProtocol {
    var title: String {
        return "Search"
    }
    
    var searchBarTitle: String {
        return "Search \(currentScope.displayTitle.capitalized)"
    }
    
    var mediaCount: Int {
        return viewModel.count
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
        isLoading = true 
        interactor.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
    func viewWillAppear() {}
    
    func getMedia(_ category: MediaCategory = .search) -> [MediaViewModel] {
        switch category {
        case .search:
            return viewModel
        case .nowPlaying:
            return nowPlayingViewModel
        case .popular:
            return popularMediaViewModel
        case .upcoming:
            return upcomingMediaViewModel
        case .topRated:
            return topRatedMediaViewModel
        case .trending:
            return trendingMediaViewModel
        case .recentlyViewed:
            return []
        case .lastSearch:
            return []
        }
    }
    
    func getSections() -> [Section] {
        switch currentScope {
        case .movies:
            return currentQuery.isEmpty ? [.popularMovies] : [.movies]
        case .series:
            return currentQuery.isEmpty ? [.popularShows] : [.tvshows]
        }
    }
    
    //This code is duplicated in the FavoritesPresenter, see a way to refactor this
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
    func isFavorite(viewModel: MediaViewModel) -> Bool {
        interactor.isMovieInFavorites(media: viewModel)
    }
    func handleFavoriteAction(at index: Int) {
        interactor.handleFavoriteAction(with: viewModel[index])
    }
    func handleFavoriteAction(viewModel: MediaViewModel) {
        interactor.handleFavoriteAction(with: viewModel)
    }
    
    func didSelectCell(at index: Int) {
        let media = viewModel[index]
        router?.navigateToDetailScreen(with: media)
    }
    
    func updateSearchResults(with query: String, scope: SearchScope) {
        guard !(query == currentQuery && scope == currentScope) else { return }
        self.currentQuery = query
        self.currentScope = scope
        self.currentPage = 1
        
        self.isLoading = true 
        interactor.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
}

//MARK: - MainScreenPresenterLoadingInputProtocol Conformance
// Protocol that needs conformance only when retrieving data from the internet
extension MainScreenPresenter: MainScreenPresenterLoadingInputProtocol {
    func isLoadingPage() -> Bool {
        self.isLoading
    }
    
    func viewShouldFetchNewPage() {
        currentPage += 1
        
        self.isLoading = true
        interactor.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
}

//MARK: - MainScreenInteractorOutputProtocol Conformance
// Called by Interactor, implemented by Presenter
extension MainScreenPresenter: MainScreenInteractorOutputProtocol {
    func presentMediaAddedToFavorites() {
        output?.showAlertFavoritedMedia()
    }
    func presentMediaRemovedFromFavorites() {
        output?.showAlertUnfavoritedMedia()
    }
    
    func didReceiveMovies(_ movies: [MediaViewModel], with page: Int) {
        self.isLoading = false
        if page == 1 {
            self.viewModel = movies
        } else {
            self.viewModel.append(contentsOf: movies)
        }
    }
    
    func didEncounterError(_ error: Error) {
        self.isLoading = false
        output?.showError(error)
    }
}
