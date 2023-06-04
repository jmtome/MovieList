//
//  MediaDetailPresenter.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import Foundation

// MARK: - Presenter

//Called by Presenter, Implemented by MediaDetailViewController
protocol MediaDetailPresenterOutputProtocol: AnyObject {
    func updateUI()
}

protocol MediaDetailPresenterInputProtocol: AnyObject {
    var title: String? { get }
    func viewDidLoad()
    
    func getMediaImages() -> [MediaImage]
    func getViewModel() -> MediaViewModel?
}

protocol MediaDetailRouterProtocol { }

class MediaDetailPresenter {
    weak var output: MediaDetailPresenterOutputProtocol?
    
    var interactor: MediaDetailInteractorInputProtocol
    var router: MediaDetailRouterProtocol
    
    private var isLoading: Bool = false
    
    private let mediaTypeId: MediaTypeID
    
    private var viewModel: MediaViewModel? {
        didSet {
            output?.updateUI()
        }
    }
    
    init(interactor: MediaDetailInteractorInputProtocol, router: MediaDetailRouterProtocol, mediaTypeId: MediaTypeID) {
        self.interactor = interactor
        self.router = router
        self.mediaTypeId = mediaTypeId
    }
}

extension MediaDetailPresenter: MediaDetailPresenterInputProtocol {
    func getViewModel() -> MediaViewModel? {
        return viewModel
    }
    
    var title: String? {
        return viewModel?.title
    }
    
    func viewDidLoad() {
        isLoading = true
        
        interactor.fetchMediaDetails(for: self.mediaTypeId)
//        interactor.fetchMediaCredits(for: self.mediaTypeId)
    }
    
    func getMediaImages() -> [MediaImage] {
        guard let viewModel else { return [] }
        let mediaImages = viewModel.backdrops.isEmpty ? viewModel.posters : viewModel.backdrops
        return mediaImages
    }
}

extension MediaDetailPresenter: MediaDetailInteractorOutputProtocol {
    func didReceiveMediaDetails(_ media: MediaViewModel) {
        isLoading = false
        
        self.viewModel = media
        interactor.fetchMediaImages(for: (type: media.type, id: media.id))
        interactor.fetchMediaCredits(for: (type: media.type, id: media.id))
    }
    
    func didReceiveMediaImages(backdrops: [MediaImage], posters: [MediaImage]) {
        isLoading = false
        
        viewModel?.backdrops.append(contentsOf: backdrops)
        viewModel?.posters.append(contentsOf: posters)
    }
    
    func didReceiveMediaCredits(_ credits: MediaCredits) {
        isLoading = false
        
        viewModel?.credits = credits
        //no se si tener todos los creditos sea lo mejor, al menos no como vienen, quiza toque hacer alguna interfaz/ adaptador/ metodo del vm
    }
    
    
    func didReceiveError(_ error: Error) {
        isLoading = false
    }
    
}
