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
    func presentMediaAddedToFavorites(mediaId: Int)
    func presentMediaRemovedFromFavorites(mediaId: Int)
    func didReceiveMovies(_ movies: [MediaViewModel], with page: Int, category: MediaCategory)
    func didEncounterError(_ error: Error)
}

//MARK: - MainScreenInteractorProtocol (Input)
// Called by Presenter, Implemented by Interactor
protocol MainScreenInteractorProtocol: AnyObject {
    func searchMedia(with query: String, scope: SearchScope, page: Int)

    func isMovieInFavorites(media: MediaViewModel) -> Bool
    func handleFavoriteAction(with media: MediaViewModel)
    
    func getNowPlayingMedia(scope: SearchScope, page: Int)
    func getPopularMedia(scope: SearchScope, page: Int)
    func getUpcomingMedia(scope: SearchScope, page: Int)
    func getTopRatedMedia(scope: SearchScope, page: Int)
    func getTrendingMedia(scope: SearchScope, page: Int)
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

extension MainScreenInteractor {
    func getNowPlayingMedia(scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getNowPlayingMedia(language: "", page: page, region: "", timezone: "", searchScope: scope)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .nowPlaying)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .nowPlaying)
                }
            } catch let error {
                print("error decoding now-playing media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
    func getPopularMedia(scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getPopularMedia(language: "", page: page, region: "", searchScope: scope)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .popular)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .popular)
                }
            } catch let error {
                print("error decoding get-popular media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
    func getUpcomingMedia(scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getUpcomingMedia(language: "", page: page, region: "", timezone: "", searchScope: scope)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .upcoming)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .upcoming)
                }
            } catch let error {
                print("error decoding get-upcoming media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
    func getTopRatedMedia(scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getTopRatedMedia(language: "", page: page, region: "", searchScope: scope)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .topRated)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .topRated)
                }
            } catch let error {
                print("error decoding get-top-rated media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
    func getTrendingMedia(scope: SearchScope, page: Int) {
        Task {
            do {
                let data = try await networkingService.getTrendingMedia(page: page, searchScope: scope)
                
                switch scope {
                case .movies:
                    let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .trending)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .trending)
                }
            } catch let error {
                print("error decoding get-trending media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
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
                    output?.didReceiveMovies(moviesResponse.results.map { MediaViewModel(movie: $0) }, with: page, category: .search)
                case .series:
                    let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                    output?.didReceiveMovies(seriesResponse.results.map { MediaViewModel(tvshow: $0) }, with: page, category: .search)
                }
            } catch let error {
                print("error decoding popular media for scope: \(scope), page: \(page), error: \(error)")
                output?.didEncounterError(error)
            }
        }
    }
        
    func isMovieInFavorites(media: MediaViewModel) -> Bool {
        favoritesRepository.isMediaInFavorites(media: media)
    }
    func handleFavoriteAction(with media: MediaViewModel) {
        if isMovieInFavorites(media: media) {
            favoritesRepository.removeFavorite(media: media)
            output?.presentMediaRemovedFromFavorites()
        } else {
            favoritesRepository.saveFavorite(media: media)
            output?.presentMediaAddedToFavorites()
        }
    }

}

