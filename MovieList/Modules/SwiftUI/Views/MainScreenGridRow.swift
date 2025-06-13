//
//  MainScreenGridRow.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 14/10/2024.
//


import SwiftUI
import MovieListFramework

struct MainScreenGridRow: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    let mediaCategory: MediaCategory
    @State var isPressed: Bool = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    let rows = [
        GridItem(.fixed(120))
    ]
    
    private var mediaData: [MediaViewModel] {
        switch mediaCategory {
        case .popular:
            return newVM.popularMedia
        case .topRated:
            return newVM.topRatedMedia
        case .upcoming:
            return newVM.upcomingMedia
        case .search:
            return filteredData
        case .nowPlaying:
            return newVM.nowPlayingMedia
        case .trending:
            return newVM.trendingMedia
        case .recentlyViewed:
            return newVM.recentlyViewedMedia
        case .lastSearch:
            return newVM.lastSearch
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if mediaCategory != .lastSearch && mediaCategory != .recentlyViewed && mediaCategory != .search {
                HStack {
                    Text(mediaCategory.title())
                    Spacer()
                    
                    NavigationLink(
                        destination:
                            VStack {
                                MainScreenVerticalGrid(newVM: newVM, filteredData: mediaData)
                            }
                            .navigationTitle(mediaCategory.title())
                    ) {
                        Image(systemName: "chevron.right")
                            .padding(.trailing)
                            .tint(.white)
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, alignment: .center, spacing: 20) {
                    ForEach(mediaData, id: \.id) { mediaItem in
                        NavigationLink(destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem)) {
                            MediaCellGridView(media: mediaItem, isFavorite: newVM.isFavorite(mediaItem))
                                .scaleEffect(isPressed ? 1.1 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isPressed)
                                .onLongPressGesture(minimumDuration: 1.2, perform: {
                                    impactFeedback.impactOccurred()
                                    withAnimation {
                                        isPressed = true
                                    }
                                    // Reset after a moment
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                        withAnimation {
                                            isPressed = false
                                        }
                                    }
                                })
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
                .padding(.vertical, 10)
            }
        }
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
    
    MainScreenGridRow(newVM: store, filteredData: dummyData, mediaCategory: .search)
        .preferredColorScheme(.dark)
}
