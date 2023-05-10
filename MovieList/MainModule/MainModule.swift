//
//  MainModule.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//


/*
               /- - -  <ViewProtocol>
               |           ^
               v           |
 ViewController   ---> Presenter -> Interactor -> Entity
                                    |
                                    v
                                Networking
 */


import UIKit

class MainScreenBuilder {
    static func build(favoritesRepository: FavoritesRepository? = nil) -> UIViewController {
        let viewController = MainScreenViewController()
        let presenter = MainScreenPresenter(view: viewController,
                                            router: MainScreenRouter())
        let interactor = MainScreenInteractor(networkingService: TMDBNetworkingService(), presenter: presenter)
        interactor.favoritesRepository = favoritesRepository
        
        presenter.interactor = interactor
        viewController.presenter = presenter
        
        return viewController
    }
}
