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
        
        let interactor = FavoritesScreenInteractor(favoritesRepository: favoritesRepository)
        let router = MainScreenRouter(viewController)
        
        let presenter = FavoritesScreenPresenter(interactor: interactor, router: router)
        
        interactor.output = presenter
        presenter.output = viewController
        
        viewController.presenter = presenter
        viewController.loadingPresenter = nil
        
        return viewController
    }
}

