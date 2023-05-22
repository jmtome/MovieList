//
//  MediaDetailBuilder.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import UIKit

class MediaDetailBuilder {
    static func build(with media: MediaViewModel) -> UIViewController {
        let viewController = MediaDetailViewController()
        let presenter = MediaDetailPresenter(view: viewController,
                                             router: MediaDetailRouter(),
                                             media: media)
        let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService(),
                                              presenter: presenter)

        
        presenter.interactor = interactor
        viewController.presenter = presenter
        
        return viewController
    }
}
