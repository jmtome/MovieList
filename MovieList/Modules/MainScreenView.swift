//
//  MainScreenView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 24/09/2024.
//

import SwiftUI
import MovieListFramework

class MediaViewStore: ObservableObject {
    @Published var mediaVM: [MediaViewModel] = []
    var presenter: MainScreenPresenterInputProtocol
    var loadPresenter: MainScreenPresenterLoadingInputProtocol
    
    init(presenter: MainScreenPresenterInputProtocol, loadPresenter: MainScreenPresenterLoadingInputProtocol) {
        self.presenter = presenter
        self.loadPresenter = loadPresenter
    }
    
    func fetchMedia() {
        presenter.viewDidLoad()
    }
    func getMedia() {
        self.mediaVM = presenter.getMedia()
    }
    func isFavorite(_ media: MediaViewModel) -> Bool {
        presenter.isFavorite(viewModel: media)
    }
    func handleFavorite(_ media: MediaViewModel) {
        presenter.handleFavoriteAction(viewModel: media)
    }
    func updateSearchResults(with query: String, scope: SearchScope) {
        presenter.updateSearchResults(with: query, scope: scope)
    }
    func fetchNewPage() {
        loadPresenter.viewShouldFetchNewPage()
    }
    func isLoadingPage() -> Bool {
        loadPresenter.isLoadingPage()
    }
    var sortOption: SortingOption {
        get {
            presenter.sortOption
        } set {
            presenter.sortOption = newValue
        }
    }
    var isAscending: Bool {
        get {
            presenter.isAscending
        } set {
            presenter.isAscending = newValue
        }
    }
    var searchBarTitle: String {
        presenter.searchBarTitle
    }
    var title: String {
        presenter.title
    }
}

extension MediaViewStore: MainScreenPresenterOutputProtocol {
    func updateUIList() {
        print("#### in uikit here i updated the snapshot of the tableview")
        
        DispatchQueue.main.async {
            self.mediaVM = self.presenter.getMedia()
        }
    }
    
    func showError(_ error: any Error) {
        print("#### show error")
    }
    
    func showAlertFavoritedMedia() {
        print("#### show alert favorited media")
    }
    
    func showAlertUnfavoritedMedia() {
        print("#### show alert unfavorited media")
    }
    
    func didUpdateMedia(with media: [MediaViewModel]) {
        self.mediaVM = media
    }
}


//protocol MainScreenPresenterInputProtocol: AnyObject {
//    var mediaCount: Int { get }
//
//    func getSections() -> [Section]
//
//    func sortMedia(with option: SortingOption)
//
//    func didSelectCell(at index: Int)
//
//}



struct MainScreenView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MainScreenView()
}
