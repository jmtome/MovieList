//
//  FavoritesBuilder.swift
//  MovieList
//
//  Created by macbook on 05/05/2023.
//

import UIKit

class FavoritesBuilder {
    static func build(favoritesRepository: FavoritesRepository) -> UIViewController {
        let interactor = FavoritesInteractor(favoritesRepository: favoritesRepository)
        let presenter = FavoritesPresenter(interactor: interactor)
        let viewController = FavoritesViewController(presenter: presenter)
        presenter.view = viewController
        interactor.presenter = presenter

        return viewController
    }
}

