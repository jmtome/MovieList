//
//  MainScreenView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 24/09/2024.
//

import SwiftUI
import MovieListFramework

enum HomeMode {
    case list, grid
    
    func icon() -> String {
        switch self {
        case .list: return "rectangle.3.offgrid.fill"
        case .grid: return "rectangle.grid.1x2"
        }
    }
}

class MediaViewStore: ObservableObject {
    //Binded Observed everchanging properties
    @Published var mediaVM: [MediaViewModel] = [] {
        didSet {
            if justSearched {
                self.lastSearch = self.mediaVM
                justSearched = false
            }
        }
    }
    
    @Published var nowPlayingMedia: [MediaViewModel] = []
    @Published var popularMedia: [MediaViewModel] = []
    @Published var upcomingMedia: [MediaViewModel] = []
    @Published var topRatedMedia: [MediaViewModel] = []
    @Published var trendingMedia: [MediaViewModel] = []

    @Published var recentlyViewedMedia: [MediaViewModel] = [] {
        didSet {
            saveRecentlyViewedMedia()
        }
    }
    
    @Published var lastSearch: [MediaViewModel] = [] {
        didSet {
            saveLastSearchMedia()
        }
    }
    private var justSearched: Bool = false

    @Published var favoritesVM: [MediaViewModel] = []
    @Published var searchTitle: String = ""
    @Published var isFetchingAll: Bool = false
    
    //Viper Actors
    var presenter: MainScreenPresenterInputProtocol
    var loadPresenter: MainScreenPresenterLoadingInputProtocol
    var favoritesPresenter: FavoritesScreenPresenter
    
    private let recentlyViewedKey = "recentlyViewedMedia"
    private let lastSearchMediaKey = "lastSearchMedia"

    
    //Store Init
    init(presenter: MainScreenPresenterInputProtocol, loadPresenter: MainScreenPresenterLoadingInputProtocol, favoritesPresenter: FavoritesScreenPresenter) {
        self.presenter = presenter
        self.favoritesPresenter = favoritesPresenter
        self.loadPresenter = loadPresenter
        self.searchTitle = presenter.searchBarTitle
        
        loadRecentlyViewedMedia() // Load from UserDefaults
        loadLastSearchMedia()
    }
    
    //ViewModel (Store) Methods
    func fetchMedia() {
        if !isLoadingPage() {
            presenter.viewDidLoad()
        }
        favoritesPresenter.viewDidLoad()
    }
    func fetchNowPlaying() {
        presenter.fetchNowPlayingMedia()
    }
    func fetchpopular() {
        presenter.fetchpopularMedia()
    }
    func fetchUpcoming() {
        presenter.fetchUpcomingMedia()
    }
    func fetchtopRated() {
        presenter.fetchTopRatedMedia()
    }
    func fetchtrendings() {
        presenter.fetchtrendingsMedia()
    }
    func fetchAllCategories(scope: SearchScope) {
        isFetchingAll = true
        presenter.fetchAllCategories(scope)
    }
    func stoppedFetchingAll() {
        isFetchingAll = (nowPlayingMedia.isEmpty || popularMedia.isEmpty || upcomingMedia.isEmpty || topRatedMedia.isEmpty || trendingMedia.isEmpty)
    }

    func fetchFavorites() {
        favoritesPresenter.viewDidLoad()
    }
    @MainActor
    func getMedia() {
        self.mediaVM = presenter.getMedia(.search)
    }
    func isFavorite(_ media: MediaViewModel) -> Bool {
        presenter.isFavorite(viewModel: media)
    }
    func handleFavorite(_ media: MediaViewModel) {
        presenter.handleFavoriteAction(viewModel: media)
        favoritesPresenter.viewDidLoad()
    }

    func updateSearchResults(with query: String, scope: SearchScope, fromFavorites: Bool = false) {
        presenter.updateSearchResults(with: query, scope: scope)
        favoritesPresenter.updateSearchResults(with: query, scope: scope)
        self.searchTitle = presenter.searchBarTitle
        
        if !fromFavorites {
            self.justSearched = true
        }

    }
    func fetchNewPage() {
        if !isLoadingPage() {
            self.loadPresenter.viewShouldFetchNewPage()
        }
    }
    func isLoadingPage() -> Bool {
        let isLoading = loadPresenter.isLoadingPage()
        print("#### is loading: \(isLoading)")
        return isLoading
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
    var mediaCount: Int {
        presenter.mediaCount
    }
    
    func sortMedia(sortOption: SortingOption) {
        guard presenter.sortOption.title != sortOption.title else {
            presenter.isAscending.toggle()
            self.presenter.sortMedia(with: sortOption)
            return
        }
        
        presenter.isAscending = true
        presenter.sortOption = sortOption
        
        presenter.sortMedia(with: sortOption)
    }
    
    func buildStoreForDetails(with media: MediaViewModel) -> MediaDetailStore {
        let mediaDetails = MediaTypeID(media.type, media.id)
        let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
        
        let presenter = MediaDetailPresenter(interactor: interactor, router: MediaDetailRouter(), mediaTypeId: mediaDetails)
        interactor.output = presenter
        let store = MediaDetailStore(presenter: presenter, onDismissClosure: { self.fetchMedia() })
        // Update the recentlyViewedMedia
        store.onSeenClosure = { seenViewModel in
            DispatchQueue.main.async {
                self.addRecentlyViewedMedia(seenViewModel)
                print("#### recentlyViewedMedia count is :\(self.recentlyViewedMedia.count)")
            }
        }
        presenter.output = store
        
        return store
    }
    // Add to recentlyViewedMedia and persist
    private func addRecentlyViewedMedia(_ media: MediaViewModel) {
        // Remove any existing media with the same ID
        recentlyViewedMedia.removeAll { $0.id == media.id }
        
        // Insert the new item at the front
        recentlyViewedMedia.insert(media, at: 0)
        
        // Limit the array to 20 items
        if recentlyViewedMedia.count > 20 {
            recentlyViewedMedia.removeLast()
        }
    }
    
    // MARK: - Persistence
    private func saveRecentlyViewedMedia() {
        do {
            let data = try JSONEncoder().encode(recentlyViewedMedia)
            UserDefaults.standard.set(data, forKey: recentlyViewedKey)
        } catch {
            print("#### Failed to save recently viewed media: \(error)")
        }
    }
    private func saveLastSearchMedia() {
        do {
            let data = try JSONEncoder().encode(lastSearch)
            UserDefaults.standard.set(data, forKey: lastSearchMediaKey)
        } catch {
            print("#### Failed to save recently viewed media: \(error)")
        }
    }
    
    private func loadLastSearchMedia() {
        if let data = UserDefaults.standard.data(forKey: lastSearchMediaKey) {
            do {
                let savedMedia = try JSONDecoder().decode([MediaViewModel].self, from: data)
                lastSearch = savedMedia
            } catch {
                print("Failed to load recently viewed media: \(error)")
            }
        }
    }
    
    func clearLastSearchMedia() {
        lastSearch.removeAll() // Clear the array
        UserDefaults.standard.removeObject(forKey: lastSearchMediaKey) // Remove persisted data
    }
    
    private func loadRecentlyViewedMedia() {
        if let data = UserDefaults.standard.data(forKey: recentlyViewedKey) {
            do {
                let savedMedia = try JSONDecoder().decode([MediaViewModel].self, from: data)
                recentlyViewedMedia = savedMedia
            } catch {
                print("Failed to load recently viewed media: \(error)")
            }
        }
    }
    
    // MARK: - Clear recently viewed media
    func clearRecentlyViewedMedia() {
        recentlyViewedMedia.removeAll() // Clear the array
        UserDefaults.standard.removeObject(forKey: recentlyViewedKey) // Remove persisted data
    }
}

extension MediaViewStore: MainScreenPresenterOutputProtocol {
    func updateUINowPlaying() {
        DispatchQueue.main.async {
            self.nowPlayingMedia = self.presenter.getMedia(.nowPlaying)
            self.stoppedFetchingAll()
        }
    }
    
    func updateUIPopular() {
        DispatchQueue.main.async {
            self.popularMedia = self.presenter.getMedia(.popular)
            self.stoppedFetchingAll()
        }
    }
    
    func updateUIUpcoming() {
        DispatchQueue.main.async {
            self.upcomingMedia = self.presenter.getMedia(.upcoming)
            self.stoppedFetchingAll()
        }
    }
    
    func updateUITopRated() {
        DispatchQueue.main.async {
            self.topRatedMedia = self.presenter.getMedia(.topRated)
            self.stoppedFetchingAll()
        }
    }
    
    func updateUITrending() {
        DispatchQueue.main.async {
            self.trendingMedia = self.presenter.getMedia(.trending)
            self.stoppedFetchingAll()
        }
    }
    
    func updateUIList() {
        print("#### in uikit here i updated the snapshot of the tableview")
        
        DispatchQueue.main.async {
            self.mediaVM = self.presenter.getMedia(.search)
            self.favoritesVM = self.favoritesPresenter.getMedia(.search)
//            print("#### favorites are: \(self.favoritesVM)")
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

struct MainScreenView: View {
    //To Remove
    let dataSource: [MediaViewModel]
    
    //Properties
    @StateObject var newVM: MediaViewStore
    @State private var searchText = ""
    @State private var segmentedScope: Int = 0
    
    @State private var tabSelection: Int = 0
    
    //For Sorting, move to VM?
    @State private var selectedSortingOption: SortingOption = .relevance
    @State private var isAscending: Bool = false
    
    @State private var homeMode: HomeMode = .grid
    private var searchTitle: String {
        newVM.searchTitle
    }
    
    private var filteredData: [MediaViewModel] {
        if searchText.isEmpty {
            return newVM.mediaVM.isEmpty ? dataSource : newVM.mediaVM
        } else {
            return newVM.mediaVM.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    private var filteredFavoriteData: [MediaViewModel] {
//        if searchText.isEmpty {
//            return newVM.favoritesVM
//        } else {
//            return newVM.favoritesVM.filter { $0.title.lowercased().contains(searchText.lowercased()) }
//        }
        return newVM.favoritesVM
    }
    @State private var isPressed = false
    @State private var navigateToDetails: Bool = false
    @State private var lastSegmentedScope: Int = 0
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        NavigationStack {
            VStack {
                // Tab View with lists
                if tabSelection != 1 {
                    Picker("Select Scope", selection: $segmentedScope) {
                        Text("Movies").tag(0)
                        Text("Series").tag(1)
                    }
                    .padding(.top, 4)
                    .pickerStyle(.segmented)
                    .onChange(of: segmentedScope) {
                        changedScope()
                    }
                }
                TabView(selection: $tabSelection) {
                    MainTabView(newVM: newVM, filteredData: filteredData, homeMode: homeMode)
                        .tabItem {
                            Label("Main", systemImage: "film")
                        }
                        .tag(0)
                    SearchTabView(viewModel: newVM, searchScope: $segmentedScope, homeMode: homeMode)
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(1)
                    FavoritesTabView(newVM: newVM, filteredFavoriteData: filteredFavoriteData, homeMode: homeMode)
                        .tabItem {
                            Label("Favorites", systemImage: "star.fill")
                        }
                        .tag(2)
//                    ListsTabView()
//                        .tabItem {
//                            Label("Lists", systemImage: "list.bullet")
//                        }
//                        .tag(3)
                }
            }
//            .navigationTitle(tabSelection == 0 ? "" : (tabSelection == 1 ? "Search" : (tabSelection == 2 ? "Favorites" : "Lists")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: tabSelection == 0 ? "popcorn.fill" : (tabSelection == 1 ? "magnifyingglass" : (tabSelection == 2 ? "star.fill" : "bookmark.fill")))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        Text(tabSelection == 0 ? "MovieList" : (tabSelection == 1 ? "Search" : (tabSelection == 2 ? "Favorites" : "Lists"))).font(.title).bold()
                    }
                }
            }
            .toolbar {
                if homeMode == .list && tabSelection == 1 {
                    ToolbarItem(placement: .automatic) {
                        SortMenuView(sortOption: $selectedSortingOption, isAscending: $isAscending)
                    }
                }
                if tabSelection == 1 || tabSelection == 2 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                self.homeMode = self.homeMode == .grid ? .list : .grid
                                impactFeedback.impactOccurred()
                            }
                        }) {
                            HStack {
                                Image(systemName: self.homeMode.icon())
                                    .imageScale(.medium)
                            }
                            .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
        .onChange(of: tabSelection) {
            impactFeedback.impactOccurred()
            if tabSelection == 2 {
                newVM.fetchFavorites()
            }
            
            if tabSelection == 1 {
                homeMode = .list
            } else {
                homeMode = .grid
            }
        }
        .onChange(of: searchText) { changedSearchOrScope() }
        .onChange(of: selectedSortingOption) { sortingChanged() }
        .onChange(of: isAscending) { sortingChanged() }
        .onAppear {
            if tabSelection == 1 {
                homeMode = .list
            } else {
                homeMode = .grid
            }
            newVM.fetchAllCategories(scope: .movies)
        }
    }
    private func sortingChanged() {
        impactFeedback.impactOccurred()
        newVM.sortMedia(sortOption: selectedSortingOption)
    }
    private func changedScope() {
        impactFeedback.impactOccurred()
        guard let scope = SearchScope(rawValue: segmentedScope) else { return }
        if tabSelection == 2 {
            print("#### fetching normal media")
            newVM.updateSearchResults(with: searchText, scope: scope, fromFavorites: true)
        } else {
            print("#### fetching all cats")
            newVM.fetchAllCategories(scope: scope)
        }
    }
    private func changedSearchOrScope() {
        impactFeedback.impactOccurred()
        guard let scope = SearchScope(rawValue: segmentedScope) else { return }
        newVM.updateSearchResults(with: searchText, scope: scope)
    }
}

#Preview {
    var dummyData: [MediaViewModel] = {
        var myData: [MediaViewModel] = []
        for index in 0..<20 {
            myData.append(MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: index)))
        }
        return myData
    }()
    let interactor = MainScreenInteractor(networkingService: TMDBNetworkingService(), favoritesRepository: FavoritesRepository())
    let router = MainScreenRouter(UIViewController())
    let presenter = MainScreenPresenter(interactor: interactor, router: router)
    
    let favoritesInteractor = FavoritesScreenInteractor(favoritesRepository: FavoritesRepository())
    let favoritesRouter = MainScreenRouter(UIViewController())
    
    let favoritesPresenter = FavoritesScreenPresenter(interactor: favoritesInteractor, router: favoritesRouter)
    
    let store = MediaViewStore(presenter: presenter, loadPresenter: presenter, favoritesPresenter: favoritesPresenter)
    
    MainScreenView(dataSource: dummyData, newVM: store)
        .preferredColorScheme(.dark)
}

struct ListsTabView: View {
    @State var segmentedScope: Int = 0
    var body: some View {
        VStack {
            Text("Lists")
            Spacer()
            
            Picker("Select Scope", selection: $segmentedScope) {
                Text("Watchlist").tag(0)
                Text("Favorites").tag(1)
                Text("Watched").tag(2)
            }
//            .padding(.top, 4)
            .pickerStyle(.segmented)
            .onChange(of: segmentedScope) { changedScope() }
        }
        
    }
    private func changedScope() {
        
    }
}

struct MainTabView: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    let homeMode: HomeMode
    
    var body: some View {
        if homeMode == .list {
            MainScreenList(newVM: newVM, filteredData: filteredData)
                .transition(.slide) // Add a sliding transition
        } else {
            MainScreenGrid(newVM: newVM, filteredData: filteredData)
        }
    }
}
struct FavoritesTabView: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredFavoriteData: [MediaViewModel]
    let homeMode: HomeMode
    
    var body: some View {
        if homeMode == .list {
            MainScreenFavoritesList(newVM: newVM, filteredFavoriteData: filteredFavoriteData)
        } else {
            MainScreenFavoritesGrid(newVM: newVM, filteredFavoriteData: filteredFavoriteData)
        }
    }
}

// For future reference

/*
 //        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: searchTitle)
         //        .searchScopes($segmentedScope, activation: .onSearchPresentation) {
         //            Text("Movies").tag(0)
         //            Text("Series").tag(1)
         //        }
 */
