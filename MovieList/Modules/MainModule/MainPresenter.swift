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
    
    func viewDidLoad()
    func viewWillAppear()
    
    func getMedia() -> [MediaViewModel]
    func getSections() -> [Section]
    
    func sortMedia(with option: SortingOption)
    
    func isFavorite(at index: Int) -> Bool
    func handleFavoriteAction(at index: Int)
    
    func didSelectCell(at index: Int)
    
    func updateSearchResults(with query: String, scope: SearchScope) 
}

protocol MainScreenPresenterLoadingInputProtocol: AnyObject {
    func isLoadingPage() -> Bool
    func viewShouldFetchNewPage()
}

//MARK: - MainScreenPresenter
class MainScreenPresenter {
    private var currentQuery: String = ""
    private var currentScope: SearchScope = .movies
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    
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
    
    func viewDidLoad() {
        interactor.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
    func viewWillAppear() {}
    
    func getMedia() -> [MediaViewModel] {
        return viewModel
    }
    func getSections() -> [Section] {
        switch currentScope {
        case .movies:
            return currentQuery.isEmpty ? [.popularMovies] : [.movies]
        case .series:
            return currentQuery.isEmpty ? [.popularShows] : [.tvshows]
        }
    }
    
    func sortMedia(with option: SortingOption) {
        print("sort option is \(option)")
    }
    
    func isFavorite(at index: Int) -> Bool {
        return interactor.isMovieInFavorites(media: viewModel[index])
    }
    func handleFavoriteAction(at index: Int) {
        interactor.handleFavoriteAction(with: viewModel[index])
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
