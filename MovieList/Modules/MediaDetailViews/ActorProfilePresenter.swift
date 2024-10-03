//
//  ActorProfilePresenter.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 01/10/2024.
//

import Foundation

// MARK: - Presenter

//Called by Presenter, Implemented by MediaDetailViewController
protocol ActorProfilePresenterOutputProtocol: AnyObject {
    func updateUI()
}

protocol ActorProfilePresenterInputProtocol: AnyObject {
    func viewDidLoad()
    
    func getViewModel() -> Person?
    func fetchActorDetails(for actorId: Int)
    func fetchActorMovies(for actorId: Int)
}

protocol ActorProfileRouterProtocol { }

class ActorProfilePresenter {
    weak var output: ActorProfilePresenterOutputProtocol?
    
    var interactor: ActorProfileInteractorInputProtocol
    var router: ActorProfileRouterProtocol?
    
    private var isLoading: Bool = false
    
    
    private var viewModel: Person? {
        didSet {
            output?.updateUI()
        }
    }
    
    init(interactor: ActorProfileInteractorInputProtocol, router: ActorProfileRouterProtocol? = nil) {
        self.interactor = interactor
//        self.router = router
    }
}

extension ActorProfilePresenter: ActorProfilePresenterInputProtocol {
    func fetchActorMovies(for actorId: Int) {
        
    }
    
    func viewDidLoad() {}
    func getViewModel() -> Person? {
        viewModel
    }
    
    func fetchActorDetails(for actorId: Int) {
        isLoading = true
        self.interactor.fetchActorDetails(for: actorId)
    }
    
}

extension ActorProfilePresenter: ActorProfileInteractorOutputProtocol {
    func didEncounterError(_ error: any Error) {
        isLoading = false 
    }
    
    func didReceiveActorDetails(_ actor: Person) {
        isLoading = false
        self.viewModel = actor
    }
}
