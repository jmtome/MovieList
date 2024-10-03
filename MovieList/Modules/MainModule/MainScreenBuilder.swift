//
//  MainScreenBuilder.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit
import MovieListFramework

class MainScreenBuilder {
    static func build(favoritesRepository: FavoritesRepository, networkRepository: NetworkingService) -> UIViewController {
//        let viewController = MainScreenViewController()
        let dummyData: [MediaViewModel] = {
            var myData: [MediaViewModel] = []
            for index in 0..<20 {
                myData.append(MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: index)))
            }
            return myData
        }()
        let viewController = HostingController()
        viewController.dataSource = dummyData
        viewController.favoritesRepository = favoritesRepository
        viewController.networkingService = networkRepository
        
        
//        let interactor = MainScreenInteractor(networkingService: networkRepository, favoritesRepository: favoritesRepository)
//        let router = MainScreenRouter(viewController)
        
//        let presenter = MainScreenPresenter(interactor: interactor, router: router)
        
//        interactor.output = presenter
//        presenter.output = viewController
//        
//        viewController.presenter = presenter
//        viewController.loadingPresenter = presenter
        
        return viewController
    }
}


import UIKit
import SwiftUI
import MovieListFramework

class HostingController: UIViewController {
    var dataSource: [MediaViewModel] = []
    var networkingService: NetworkingService!
    var favoritesRepository: FavoritesRepository!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sample data for testing
        dataSource = createDummyData()
        let router = MainScreenRouter(self)
        
        // Create the SwiftUI view
        let interactor = MainScreenInteractor(networkingService: networkingService, favoritesRepository: favoritesRepository)
        let presenter = MainScreenPresenter(interactor: interactor, router: router)
        
        interactor.output = presenter
        
        //Create favorites viper actors
        let favoritesInteractor = FavoritesScreenInteractor(favoritesRepository: favoritesRepository)
        let favoritesRouter = MainScreenRouter(self)
        
        let favoritesPresenter = FavoritesScreenPresenter(interactor: favoritesInteractor, router: favoritesRouter)
        
        favoritesInteractor.output = favoritesPresenter
        
        
        let store = MediaViewStore(presenter: presenter, loadPresenter: presenter, favoritesPresenter: favoritesPresenter)
        //        store.presenter = presenter
        
        presenter.output = store
        favoritesPresenter.output = store

        let mainScreenView = MainScreenView(dataSource: dataSource, newVM: store)
        
        // Create a UIHostingController with the SwiftUI view
        let hostingController = UIHostingController(rootView: mainScreenView)
        
        // Add the hosting controller as a child
        addChild(hostingController)
        hostingController.view.frame = view.bounds // Match the frame
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    private func createDummyData() -> [MediaViewModel] {
        var myData: [MediaViewModel] = []
        for index in 0..<20 {
            myData.append(MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: index)))
        }
        return myData
    }
}
