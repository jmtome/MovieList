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
        
        let interactor = MainScreenInteractor(networkingService: networkRepository,
                                              favoritesRepository: favoritesRepository)
        let presenter = MainScreenPresenter(view: viewController,
                                            router: MainScreenRouter(viewController))
        
        
        interactor.output = presenter
        
        presenter.interactor = interactor
        viewController.presenter = presenter
        
        return viewController
    }
}
