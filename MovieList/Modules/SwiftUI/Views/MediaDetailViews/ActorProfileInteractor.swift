//
//  ActorProfileInteractor.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 01/10/2024.
//

import Foundation

protocol ActorProfileInteractorInputProtocol: AnyObject {
    func fetchActorDetails(for actorId: Int)
}
protocol ActorProfileInteractorOutputProtocol: AnyObject {
    func didReceiveActorDetails(_ actor: Person)
    func didEncounterError(_ error: Error)
}


class ActorProfileInteractor {
    weak var output: ActorProfileInteractorOutputProtocol?
    
    private let networkingService: NetworkingService
    
    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }
}

extension ActorProfileInteractor: ActorProfileInteractorInputProtocol {
    func fetchActorDetails(for actorId: Int) {
        Task {
            var actor: Person
            do {
                let actorData = try await networkingService.getActorDetails(for: actorId)
                actor = try JSONDecoder().decode(Person.self, from: actorData)
                output?.didReceiveActorDetails(actor)
            } catch let error {
                print("There was an error caught trying to fetch the Actor details for actorId: \(actorId)\n error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
    
}
