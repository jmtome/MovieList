//
//  MainScreenGrid.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 14/10/2024.
//


import SwiftUI
import MovieListFramework

struct MainScreenGrid: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    @State var isPressed: Bool = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    let rows = [
        //        GridItem(.adaptive(minimum: 80))
        GridItem(.fixed(120))
    ]
    var body: some View {
        if newVM.isFetchingAll {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(3)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .trending)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .popular)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .nowPlaying)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .upcoming)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .topRated)
                }
                .padding(.top)
                .padding(.leading)
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
    
    NavigationStack {
        MainScreenGrid(newVM: store, filteredData: dummyData)
    }
        .preferredColorScheme(.dark)
}
