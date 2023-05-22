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
    var mediaCount: Int { get }
    
    func viewDidLoad()
    
    func getMedia() -> [MediaViewModel]
    func getSections() -> [Section]
    
    func sortMedia(with option: SortingOption)
    
    func isFavorite(at index: Int) -> Bool
    func handleFavoriteAction(at index: Int)
    
    func isLoadingPage() -> Bool
    func viewShouldFetchNewPage()
    
    func didSelectCell(at index: Int)
    
    func viewDidChangeSearchScope(_ scope: SearchScope)
    func viewDidChangeSearchQuery(_ query: String)
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
    
    init(view: MainScreenPresenterOutputProtocol, router: MainScreenRouterProtocol) {
        self.output = view
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
    var mediaCount: Int {
        return viewModel.count
    }
    
    func viewDidLoad() {
        interactor?.getPopularMedia(currentScope: currentScope, page: currentPage)
    }
    
    func getMedia() -> [MediaViewModel] {
        return viewModel
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
    
    func sortMedia(with option: SortingOption) {
        print("sort option is \(option)")
    }

    func isFavorite(at index: Int) -> Bool {
        return interactor.isMovieInFavorites(media: viewModel[index])
    }
    func handleFavoriteAction(at index: Int) {
        interactor.handleFavoriteAction(with: viewModel[index])
    }
    
    func isLoadingPage() -> Bool {
        self.isLoading
    }
    func viewShouldFetchNewPage() {
        currentPage += 1
        
        self.isLoading = true
        
        guard !currentQuery.isEmpty else { interactor?.getPopularMedia(currentScope: currentScope, page: currentPage) ; return }
        interactor?.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    
    
    func didSelectCell(at index: Int) {
        let media = viewModel[index]
        router?.navigateToDetailScreen(with: media)
    }
    
    func viewDidChangeSearchScope(_ scope: SearchScope) {
        currentScope = scope
        currentPage = 1
        
        self.isLoading = true
        
        interactor.searchMedia(with: currentQuery, scope: currentScope, page: currentPage)
    }
    func viewDidChangeSearchQuery(_ query: String) {
        currentQuery = query
        currentPage = 1
        
        self.isLoading = true
        
        guard !currentQuery.isEmpty else { interactor.getPopularMedia(currentScope: currentScope, page: currentPage) ; return }
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
        output?.updateUIList()
    }
    
    func didEncounterError(_ error: Error) {
        self.isLoading = false
//        view?.displayError(error.localizedDescription)
    }
}
