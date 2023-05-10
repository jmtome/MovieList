//
//  MainRouter.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

protocol MainScreenRouterProtocol: AnyObject {
    func navigateToDetailScreen(with movie: Movie)
}

class MainScreenRouter: MainScreenRouterProtocol {
    weak var viewController: UIViewController?
    
    func navigateToDetailScreen(with movie: Movie) {
//        let detailBuilder = DetailScreenBuilder()
//        let detailViewController = detailBuilder.build(with: movie)
//        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
