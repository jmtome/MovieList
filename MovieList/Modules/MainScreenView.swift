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
    @Published var mediaVM: [MediaViewModel] = []
    @Published var favoritesVM: [MediaViewModel] = []
    @Published var searchTitle: String = ""
    
    //Viper Actors
    var presenter: MainScreenPresenterInputProtocol
    var loadPresenter: MainScreenPresenterLoadingInputProtocol
    var favoritesPresenter: FavoritesScreenPresenter
    
    //Store Init
    init(presenter: MainScreenPresenterInputProtocol, loadPresenter: MainScreenPresenterLoadingInputProtocol, favoritesPresenter: FavoritesScreenPresenter) {
        self.presenter = presenter
        self.favoritesPresenter = favoritesPresenter
        self.loadPresenter = loadPresenter
        self.searchTitle = presenter.searchBarTitle
    }
    
    //ViewModel (Store) Methods
    func fetchMedia() {
        if !isLoadingPage() {
            presenter.viewDidLoad()
        }
        favoritesPresenter.viewDidLoad()
    }
    func fetchFavorites() {
        favoritesPresenter.viewDidLoad()
    }
    @MainActor
    func getMedia() {
        self.mediaVM = presenter.getMedia()
    }
    func isFavorite(_ media: MediaViewModel) -> Bool {
        presenter.isFavorite(viewModel: media)
    }
    func handleFavorite(_ media: MediaViewModel) {
        presenter.handleFavoriteAction(viewModel: media)
        favoritesPresenter.viewDidLoad()
    }
    func updateSearchResults(with query: String, scope: SearchScope) {
        presenter.updateSearchResults(with: query, scope: scope)
        favoritesPresenter.updateSearchResults(with: query, scope: scope)
        self.searchTitle = presenter.searchBarTitle
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
        presenter.output = store
        
        return store
    }
}

extension MediaViewStore: MainScreenPresenterOutputProtocol {
    func updateUIList() {
        print("#### in uikit here i updated the snapshot of the tableview")
        
        DispatchQueue.main.async {
            self.mediaVM = self.presenter.getMedia()
            self.favoritesVM = self.favoritesPresenter.getMedia()
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
        if searchText.isEmpty {
            return newVM.favoritesVM
        } else {
            return newVM.favoritesVM.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    @State private var isPressed = false
    @State private var navigateToDetails: Bool = false
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    var body: some View {
        NavigationStack {
            VStack {
                // Tab View with lists
                Picker("Select Scope", selection: $segmentedScope) {
                    Text("Movies").tag(0)
                    Text("Series").tag(1)
                }
                .pickerStyle(.segmented)
                .onChange(of: segmentedScope) { changedSearchOrScope() }
                
                TabView(selection: $tabSelection) {
                    MainTabView(newVM: newVM, filteredData: filteredData, homeMode: homeMode)
                        .tabItem {
                            Label("Movies", systemImage: "film")
                        }
                        .tag(0)
                    FavoritesTabView(newVM: newVM, filteredFavoriteData: filteredFavoriteData, homeMode: homeMode)
                        .tabItem {
                            Label("Favorites", systemImage: "star.fill")
                        }
                        .tag(1)
                    Color.clear
                        .tabItem {
                            Label("Watch Later", systemImage: "bookmark.fill")
                        }
                        .tag(2)
                }
                .onChange(of: tabSelection) { print("#### onChange of tabSelection: \(tabSelection)")}
            }
            .navigationTitle(tabSelection == 0 ? "MovieList" : (tabSelection == 1 ? "Favorites" : "Watch Later"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    SortMenuView(sortOption: $selectedSortingOption, isAscending: $isAscending)
                }
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: searchTitle)
        //        .searchScopes($segmentedScope, activation: .onSearchPresentation) {
        //            Text("Movies").tag(0)
        //            Text("Series").tag(1)
        //        }
        .onChange(of: tabSelection) {
            impactFeedback.impactOccurred()
            newVM.fetchFavorites()
        }
        .onChange(of: searchText) { changedSearchOrScope() }
        .onChange(of: selectedSortingOption) { sortingChanged() }
        .onChange(of: isAscending) { sortingChanged() }
        .onAppear { newVM.fetchMedia() }
    }
    private func sortingChanged() {
        impactFeedback.impactOccurred()
        newVM.sortMedia(sortOption: selectedSortingOption)
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
struct MainScreenGrid: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    @State var isPressed: Bool = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(filteredData, id: \.id) { mediaItem in
                    NavigationLink(destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem)) {
                        MediaCellGridView(media: mediaItem)
                            .onAppear {
                                impactFeedback.prepare()
                            }
                            .scaleEffect(isPressed ? 5 : 1.0) // Adjust the scale value for a more dramatic effect
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isPressed) // Control the speed and bounce of the animation
                            .gesture(
                                LongPressGesture(minimumDuration: 1.5) // Adjust the duration if needed
                                    .onChanged { _ in
                                        withAnimation {
                                            isPressed = true
                                        }
                                        impactFeedback.impactOccurred()
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            isPressed = false
                                        }
                                    }
                            )
                            .contextMenu {
                                Button(action: {
                                    // Handle Favorite action
                                    newVM.handleFavorite(mediaItem)
                                }) {
                                    let isFavorite = newVM.isFavorite(mediaItem)
                                    Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "star.fill" : "star")
                                }
                                Button(action: {
                                    // Handle Bookmark action
                                }) {
                                    Label("Bookmark", systemImage: "bookmark")
                                }
                            }
                    }
                }
            }
            .padding(.top, 20)
        }
        
    }
}

struct MainScreenFavoritesGrid: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredFavoriteData: [MediaViewModel]
    @State var isPressed: Bool = false

    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80))
        ]
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(filteredFavoriteData, id: \.id) { mediaItem in
                    NavigationLink(destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem)) {
                        MediaCellGridView(media: mediaItem)
                            .onAppear {
                                impactFeedback.prepare()
                            }
                            .scaleEffect(isPressed ? 5 : 1.0) // Adjust the scale value for a more dramatic effect
                            .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isPressed) // Control the speed and bounce of the animation
                            .gesture(
                                LongPressGesture(minimumDuration: 1.5) // Adjust the duration if needed
                                    .onChanged { _ in
                                        withAnimation {
                                            isPressed = true
                                        }
                                        impactFeedback.impactOccurred()
                                    }
                                    .onEnded { _ in
                                        withAnimation {
                                            isPressed = false
                                        }
                                    }
                            )
                            .contextMenu {
                                Button(action: {
                                    // Handle Favorite action
                                    newVM.handleFavorite(mediaItem)
                                }) {
                                    let isFavorite = newVM.isFavorite(mediaItem)
                                    Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "star.fill" : "star")
                                }
                                Button(action: {
                                    // Handle Bookmark action
                                }) {
                                    Label("Bookmark", systemImage: "bookmark")
                                }
                            }
                    }
                }
            }
        }
    }
}

struct MainScreenList: View {
    @ObservedObject var newVM: MediaViewStore
    @State private var scrollViewPosition: Int? = 0
    let filteredData: [MediaViewModel]
    @State var scrolledValue: CGFloat = 0
    var body: some View {
        VStack {
            List(filteredData, id: \.id) { mediaItem in
                MediaCellListView(media: mediaItem)
                    .background(
                        NavigationLink("", destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem))
                            .opacity(0)
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            newVM.handleFavorite(mediaItem)
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                            
                        } label: {
                            TrailingActionCircularImage2(isActive: newVM.isFavorite(mediaItem), actionType: .favorite)
                        }
                        .tint(.clear)
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .heavy)
                            generator.impactOccurred()
                        } label: {
                            TrailingActionCircularImage2(isActive: false, actionType: .bookmark)
                        }
                        .tint(.clear)
                    }
            }
            .listStyle(.plain)
        }
    }
}

struct MainScreenFavoritesList: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredFavoriteData: [MediaViewModel]
    var body: some View {
        List(filteredFavoriteData, id: \.id) { mediaItem in
            MediaCellListView(media: mediaItem)
                .background(
                    NavigationLink("", destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem))
                        .opacity(0)
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        newVM.handleFavorite(mediaItem)
                    } label: {
                        TrailingActionCircularImage(isFavorite: newVM.isFavorite(mediaItem))
                    }
                    .tint(.clear)
                }
        }
        .listStyle(.plain)
    }
}



/*
 struct MainScreenGrid: View {
     @ObservedObject var newVM: MediaViewStore
     let filteredData: [MediaViewModel]
     @State var isPressed: Bool = false
     
     private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

     let columns = [
         GridItem(.adaptive(minimum: 80))
     ]
     @State private var scrollViewPosition: Int? = 0

     var body: some View {
         VStack {
             Text("\(scrollViewPosition)")
             ScrollView(.vertical, showsIndicators: false) {
                 LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                     ForEach(filteredData.indices, id: \.self) { mediaItemIndex in
                         NavigationLink(destination: MediaDetailView(store: newVM.buildStoreForDetails(with: filteredData[mediaItemIndex]), media: filteredData[mediaItemIndex])) {
                             MediaCellGridView(media: filteredData[mediaItemIndex])
                                 .onAppear {
                                     impactFeedback.prepare()
                                     print("$ number of items: \(filteredData.count)")
                                     print("$ number of current index: \(mediaItemIndex)")
 //                                    if mediaItemIndex == filteredData.count - 20 {
 //                                        print("$ fetching new page")
 //
 //                                        newVM.fetchNewPage()
 //                                    }
                                 }
                                 .scaleEffect(isPressed ? 5 : 1.0) // Adjust the scale value for a more dramatic effect
                                 .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isPressed) // Control the speed and bounce of the animation
                                 .gesture(
                                     LongPressGesture(minimumDuration: 1.5) // Adjust the duration if needed
                                         .onChanged { _ in
                                             withAnimation {
                                                 isPressed = true
                                             }
                                             impactFeedback.impactOccurred()
                                         }
                                         .onEnded { _ in
                                             withAnimation {
                                                 isPressed = false
                                             }
                                         }
                                 )
                                 .contextMenu {
                                     Button(action: {
                                         // Handle Favorite action
                                         newVM.handleFavorite(filteredData[mediaItemIndex])
                                     }) {
                                         let isFavorite = newVM.isFavorite(filteredData[mediaItemIndex])
                                         Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "star.fill" : "star")
                                     }
                                     Button(action: {
                                         // Handle Bookmark action
                                     }) {
                                         Label("Bookmark", systemImage: "bookmark")
                                     }
                                 }
                             // Trigger fetching more items when scrolling near the bottom
                             GeometryReader { geo in
                                 Color.clear
 //                                    .task {
 //                                        newVM.fetchNewPage()
 //                                    }
                                     .onAppear {
                                         if geo.frame(in: .global).maxY < UIScreen.main.bounds.height {
                                             newVM.fetchNewPage()
                                         }
                                     }
                             }
                         }
                     }
                 }
             }
         }
     }
 }
 */


/*.scrollTargetLayout()*/
/*.scrollPosition(id: $scrollViewPosition)*/
//        .onChange(of: scrollViewPosition) {
//            if let scrollPosition = scrollViewPosition {
//                let modulo = scrollPosition % 8
//                print("$ modulo is: \(modulo)")
//                if modulo == 0 {
//                    newVM.fetchNewPage()
//                }
//            }
//        }
