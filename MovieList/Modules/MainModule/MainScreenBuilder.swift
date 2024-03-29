//
//  MainScreenBuilder.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

class MainScreenBuilder {
    static func build(favoritesRepository: FavoritesRepository, networkRepository: NetworkingService) -> UIViewController {
        let viewController = MainScreenViewController()
        
        let interactor = MainScreenInteractor(networkingService: networkRepository, favoritesRepository: favoritesRepository)
        let router = MainScreenRouter(viewController)
        
        let presenter = MainScreenPresenter(interactor: interactor, router: router)
        
        interactor.output = presenter
        presenter.output = viewController
        
        viewController.presenter = presenter
        viewController.loadingPresenter = presenter
        
        return viewController
    }
}
