//
//  MainRouter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit


protocol MainScreenRouterProtocol: AnyObject {
    func navigateToDetailScreen(with media: MediaViewModel)
}

class MainScreenRouter: MainScreenRouterProtocol {
    weak var viewController: UIViewController?
    
    init(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    func navigateToDetailScreen(with media: MediaViewModel) {
        
        let mediaTypeId = MediaTypeID(media.type, media.id)
        
        let detailVC = MediaDetailBuilder.build(with: mediaTypeId)
        viewController?.navigationItem.backButtonTitle = ""
        viewController?.show(detailVC, sender: self)
        
    }
}
