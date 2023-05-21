//
//  MainRouter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

protocol MainScreenRouterProtocol: AnyObject {
    func navigateToDetailScreen(with media: AnyMedia)
}

class MainScreenRouter: MainScreenRouterProtocol {
    weak var viewController: UIViewController?
    
    init(_ vc: UIViewController) {
        self.viewController = vc
    }
    
    func navigateToDetailScreen(with media: AnyMedia) {
        
        let detailVC = MediaDetailBuilder.build(with: media)
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
        
        
    }
}
