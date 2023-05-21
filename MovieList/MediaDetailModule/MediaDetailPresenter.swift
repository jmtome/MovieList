//
//  MediaDetailPresenter.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import Foundation

// MARK: - Presenter

protocol MediaDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didFetchMediaDetail(_ mediaDetail: MediaDetail)
    func didFetchMediaImages(_ mediaImages: [Data])
    func didFetchMediaVideos(_ mediaVideos: [MediaVideo])
    func didFetchMediaActors(_ mediaActors: [MediaActor])
    func showError(_ error: Error)
    
    func didFinishFetchingMediaImages(_ mediaImages: [MediaImage])
    
    var media: AnyMedia { get set }
}

class MediaDetailPresenter: MediaDetailPresenterProtocol {
    weak var view: MediaDetailViewProtocol?
    var interactor: MediaDetailInteractorProtocol?
    var router: MediaDetailRouterProtocol?
    
    var media: AnyMedia
    
    func viewDidLoad() {
//        interactor?.fetchMediaDetail()
        interactor?.fetchMediaImages()
//        interactor?.fetchMediaVideos()
//        interactor?.fetchMediaActors()
        
    }
    
    init(view: MediaDetailViewProtocol, router: MediaDetailRouterProtocol, media: AnyMedia) {
        self.view = view
        self.router = router
        self.media = media
    }
 
    func didFinishFetchingMediaImages(_ mediaImages: [MediaImage]) {
        self.media.mediaImages = mediaImages
        view?.viewDidFinishLoading(with: self.media)
    }
    
    func didFetchMediaDetail(_ mediaDetail: MediaDetail) {
        // Update the view with the media detail data
        view?.displayMediaDetail(mediaDetail)
    }
    
    func didFetchMediaImages(_ mediaImages: [Data]) {
        // Update the view with the media images data
        view?.displayMediaImages(mediaImages)
    }
    
    func didFetchMediaVideos(_ mediaVideos: [MediaVideo]) {
        // Update the view with the media videos data
        view?.displayMediaVideos(mediaVideos)
    }
    
    func didFetchMediaActors(_ mediaActors: [MediaActor]) {
        // Update the view with the media actors data
        view?.displayMediaActors(mediaActors)
    }
    
    func showError(_ error: Error) {
        // Display the error on the view
        view?.displayError(error)
    }
}

// MARK: - View

