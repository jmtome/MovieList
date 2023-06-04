//
//  MediaDetailViewController.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import UIKit
import SwiftUI



class MediaDetailViewController: UIViewController {
    var presenter: MediaDetailPresenterInputProtocol!

    var carouselViewController: UIViewController!
    
    var carousel: Carousel!
    var titleAndDescription: TitleAndOverview!
    var mediaInfoView: MediaInfoView!
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let scrollViewContainer: UIStackView = {
        let view = UIStackView()
        
        view.axis = .vertical
        view.spacing = 10
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var inFavorites = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Testing title"
        navigationController?.navigationBar.prefersLargeTitles = false

        setupCarousel()
        
        updateNavBar()
        
        presenter.viewDidLoad()
        
    }
    //para poder favoritear tendria que pasar el modulo de favoritos, investigar como es la forma correcta de inyeccion de dependencias , ver el video de Essential
    //Developer, creo que hablan de esto.
    func updateNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: inFavorites ? "star.fill" : "star"), style: .plain, target: self, action: #selector(pressedFavorite))

    }
    @objc func pressedFavorite() {
        print("infavs: \(inFavorites)")
        inFavorites.toggle()
        print("infavs: \(inFavorites)")
        updateNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupCarousel() {
        
        carousel = Carousel(frame: .zero, backdrops: [], in: self.view)
        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        titleAndDescription = TitleAndOverview(frame: .zero)
        titleAndDescription.translatesAutoresizingMaskIntoConstraints = false
        
        mediaInfoView = MediaInfoView(frame: .zero)
        mediaInfoView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(scrollView)
        scrollView.addSubview(scrollViewContainer)
        scrollViewContainer.addArrangedSubview(carousel)
        scrollViewContainer.addArrangedSubview(titleAndDescription)
        scrollViewContainer.addArrangedSubview(mediaInfoView)
        
        NSLayoutConstraint.activate([
            carousel.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 0),
            carousel.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: 0),
            titleAndDescription.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 8),
            titleAndDescription.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -8),
            mediaInfoView.leadingAnchor.constraint(equalTo: scrollViewContainer.leadingAnchor, constant: 8),
            mediaInfoView.trailingAnchor.constraint(equalTo: scrollViewContainer.trailingAnchor, constant: -8)
        ])

        
        
        scrollViewContainer.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        scrollViewContainer.isLayoutMarginsRelativeArrangement = true
            
        
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        // this is important for scrolling
        scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        
       
        view.backgroundColor = .softDark


    }
    
    private func updateCarousel() {
        carousel.updateDataSource(with: presenter?.getViewModel())
        mediaInfoView.setup(presenter?.getViewModel())
        titleAndDescription.setup(with: presenter?.getViewModel())
    }
}


extension MediaDetailViewController: MediaDetailPresenterOutputProtocol {
    func updateUI() {
        updateCarousel()
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            self?.title = self?.presenter.title
        }
    }
    
    
}
