//
//  MainScreenList.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 14/10/2024.
//

import SwiftUI

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
    
    MainScreenList(newVM: store, filteredData: dummyData)
        .preferredColorScheme(.dark)
}

