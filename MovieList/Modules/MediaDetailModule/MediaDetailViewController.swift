//
//  MediaDetailViewController.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import UIKit
import SwiftUI

protocol MediaDetailViewProtocol: AnyObject {
    func displayMediaDetail(_ mediaDetail: MediaDetail)
    func displayMediaImages(_ mediaImages: [Data])
    func displayMediaVideos(_ mediaVideos: [MediaVideo])
    func displayMediaActors(_ mediaActors: [MediaActor])
    func displayError(_ error: Error)
    
    func viewDidFinishLoading(with media: AnyMedia)
}

class MediaDetailViewController: UIViewController {
    var presenter: MediaDetailPresenterProtocol?

    var carouselViewController: UIViewController!
    
    var carousel: Carousel!
    
    var images: [UIImage] = [
        UIImage(systemName: "film.circle.fill")!,
        UIImage(systemName: "film.circle")!,
        UIImage(systemName: "film.circle.fill")!,
        UIImage(systemName: "film.circle")!
    ]
    
    let mediaImages: [MediaImage] = [
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png", voteAverage: 0, voteCount: 0, width: 0),
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/2.png", voteAverage: 0, voteCount: 0, width: 0),
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/3.png", voteAverage: 0, voteCount: 0, width: 0)
    ]
//    let urls: [URL] = [
//        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")!,
//        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/2.png")!,
//        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/3.png")!
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Testing title"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        setupCarousel()
        
        presenter?.viewDidLoad()
    }
    
    func setupCarousel() {
        carousel = Carousel(frame: .zero, media: self.mediaImages, in: self.view)
//        carousel.backgroundColor = .red
        view.addSubview(carousel)
        view.backgroundColor = .systemBackground
        carousel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            carousel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            carousel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carousel.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
}

extension MediaDetailViewController: MediaDetailViewProtocol {
    func displayMediaDetail(_ mediaDetail: MediaDetail) {
        
    }
    
    func displayMediaImages(_ mediaImages: [Data]) {
        let placeholder = UIImage(systemName: "film.circle.fill")
        
        self.images = mediaImages.compactMap { UIImage(data: $0) }
        
    }
    
    func displayMediaVideos(_ mediaVideos: [MediaVideo]) {
        
    }
    
    func displayMediaActors(_ mediaActors: [MediaActor]) {
        
    }
    
    func displayError(_ error: Error) {
        
    }
    
    func viewDidFinishLoading(with media: AnyMedia) {
        DispatchQueue.main.async {
            self.title = media.title
            self.carousel.updateDataSource(with: [])
        }
    }
    
    
}


// MARK: - Router

protocol MediaDetailRouterProtocol: AnyObject {
    // Define navigation methods or transitions specific to the MediaDetail module
}

class MediaDetailRouter: MediaDetailRouterProtocol {
    weak var view: MediaDetailViewProtocol?
    
    // Implement the router methods for navigation or transitions
}

// MARK: - Entities

struct MediaDetail {
    // Define the properties for the media detail
}


struct MediaVideo {
    // Define the properties for a media video
}

struct MediaActor {
    // Define the properties for a media actor
}

