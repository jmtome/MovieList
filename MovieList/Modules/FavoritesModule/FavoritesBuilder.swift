//
//  FavoritesBuilder.swift
//  MovieList
//
//  Created by macbook on 23/05/2023.
//

import UIKit


class FavBuilder {
    static func build(favoritesRepository: FavoritesRepository, networkRepository: NetworkingService) -> UIViewController {
        //Reuse of this VC because its the exact same screen, but with a different Presenter and Interactor.
        let viewController = MainScreenViewController()
        
        let favoritesInteractor = FavoritesScreenInteractor(favoritesRepository: favoritesRepository)
        let favoritesRouter = MainScreenRouter(viewController)
        
        let favoritesPresenter = FavoritesScreenPresenter(interactor: favoritesInteractor, router: favoritesRouter)
        
        favoritesInteractor.output = favoritesPresenter
        favoritesPresenter.output = viewController
        
        viewController.presenter = favoritesPresenter
        viewController.loadingPresenter = nil
        
        return viewController
    }
}

