//
//  MediaDetailBuilder.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import UIKit

class MediaDetailBuilder {
    static func build(with mediaDetails: MediaTypeID) -> UIViewController {
        let viewController = MediaDetailViewController()
        //TODO: - Si pudiera hacer una capa de abstraccion que pudiera englobar tanto a networking como a favorites, podria ganar cierto polimorfismo de tener
        // ambas capabilities juntas, de este modo estoy teniendo que pasar de a uno la dependencia, aunque... favoritos y network en este caso no son lo mismo
        // quiza esa idea funcionaria usando una cache y no favoritos...
        let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
        
        let presenter = MediaDetailPresenter(interactor: interactor, router: MediaDetailRouter(), mediaTypeId: mediaDetails)
        
        interactor.output = presenter
        presenter.output = viewController
        viewController.presenter = presenter
    
        
        return viewController
    }
}
struct MediaDetailRouter: MediaDetailRouterProtocol {
    
}

