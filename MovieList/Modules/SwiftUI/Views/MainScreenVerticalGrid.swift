//
//  MainScreenVerticalGrid.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 14/10/2024.
//


import SwiftUI
import MovieListFramework

struct MainScreenVerticalGrid: View {
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
            .padding(.top, 20)
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
    
    MainScreenVerticalGrid(newVM: store, filteredData: dummyData)
        .preferredColorScheme(.dark)
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
        }
    }
}
