//
//  MainInteractor.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

//MARK: - MainScreenInteractorOutputProtocol
// Called by Interactor, Implemented by Presenter
protocol MainScreenInteractorOutputProtocol: AnyObject {
    func presentMediaAddedToFavorites()
    func presentMediaRemovedFromFavorites()
    func didReceiveMovies(_ movies: [MediaViewModel], with page: Int)
    func didEncounterError(_ error: Error)
}

//MARK: - MainScreenInteractorProtocol (Input)
// Called by Presenter, Implemented by Interactor
protocol MainScreenInteractorProtocol: AnyObject {
    func searchMedia(with query: String, scope: SearchScope, page: Int)
    func getPopularMedia(currentScope: SearchScope, page: Int)

    func isMovieInFavorites(media: MediaViewModel) -> Bool
    func handleFavoriteAction(with media: MediaViewModel)
}

//MARK: - MainScreenInteractor
class MainScreenInteractor {
    private let networkingService: NetworkingService
    private let favoritesRepository: FavoritesRepository
        
    weak var output: MainScreenInteractorOutputProtocol?
    
    init(networkingService: NetworkingService, favoritesRepository: FavoritesRepository) {
        self.networkingService = networkingService
        self.favoritesRepository = favoritesRepository
    }
}

//MARK: - MainScreenInteractorProtocol (Input) Conformance
// Called by Presenter, Implemented by Interactor
extension MainScreenInteractor: MainScreenInteractorProtocol {
    func searchMedia(with query: String, scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.searchMedia(query: query, scope: scope, page: page)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page)
                default:
                    break
                }
            } catch let error {
                print("error searching for shows \(error)")
            }
        }
    }
    func getPopularMedia(currentScope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getPopularMedia(scope: currentScope, page: page)
                
                switch currentScope {
                case .movies:
                    let popularMoviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    self.output?.didReceiveMovies(popularMoviesResponse.results.map { MediaViewModel(movie: $0) }, with: page)
                case .series:
                    let popularSeriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    self.output?.didReceiveMovies(popularSeriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page)
                default:
                    break
                }
            } catch let error {
                print("error decoding popular media for scope: \(currentScope), page: \(page), error: \(error)")
            }
        }
    }
    
    func isMovieInFavorites(media: MediaViewModel) -> Bool {
        favoritesRepository.isMediaInFavorites(media: media)
    }
    func handleFavoriteAction(with media: MediaViewModel) {
        if isMovieInFavorites(media: media) {
            favoritesRepository.removeFavorite(media: media)
            output?.presentMediaAddedToFavorites()
        } else {
            favoritesRepository.saveFavorite(media: media)
            output?.presentMediaRemovedFromFavorites()
        }
    }

}

