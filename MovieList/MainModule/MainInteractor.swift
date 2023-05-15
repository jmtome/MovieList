//
//  MainInteractor.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import AnyCodable


protocol MainScreenInteractorProtocol: AnyObject {
    func searchMedia(with query: String, scope: SearchScope, page: Int)
   
    func saveFavorite(with movie: AnyMedia)
    func removeFavorite(with movie: AnyMedia)
    func isMovieInFavorites(movie: AnyMedia) -> Bool
    
    func getPopularMedia(currentScope: SearchScope, page: Int)
    
    func retrieveFavorites() -> [Movie]
}

class MainScreenInteractor: MainScreenInteractorProtocol {
    
    private let networkingService: NetworkingService
    var favoritesRepository: FavoritesRepository?
    
    weak var presenter: MainScreenPresenterProtocol?
    
    init(networkingService: NetworkingService, presenter: MainScreenPresenterProtocol) {
        self.networkingService = networkingService
        self.presenter = presenter
    }
    
    func getPopularMedia(currentScope: SearchScope, page: Int) {
        
        networkingService.getPopularMedia(scope: currentScope, page: page) { result in
            switch result {
            case .success(let data):
                
                do {
                    switch currentScope {
                    case .movies:
                        let popularMoviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                        self.presenter?.didReceiveMovies(popularMoviesResponse.results.map { AnyMedia($0) }, with: page)
                    case .series:
                        let popularSeriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                        self.presenter?.didReceiveMovies(popularSeriesResponse.results.map { AnyMedia($0) }, with: page)
                    default: break
                    }
                } catch let error {
                    print("error decoding, error: \(error)")
                }
            case .failure(let error):
                break
            }
        }
        
    }
    //ver esto
    func searchMedia(with query: String, scope: SearchScope, page: Int) {
        networkingService.searchMedia(query: query,
                                      scope: scope,
                                      page: page) { result in
            switch result {
            case .success(let data):
                do {
                    switch scope {
                    case .movies:
                        let moviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                        self.presenter?.didReceiveMovies(moviesResponse.results.map { AnyMedia($0) }, with: page)
                    case .series:
                        let seriesResponse = try JSONDecoder().decode(Response<TVShow>.self, from: data)
                        self.presenter?.didReceiveMovies(seriesResponse.results.map { AnyMedia($0) }, with: page)
                    default:
                        break
                    }
                } catch let error {
                    print("error searching for shows \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    

}

extension MainScreenInteractor {
    
    //continue from here, check if this works , try to keep this logic to save
    //because makiny AnyMedia conform to Codeble is sustantially harder for retrieving objects
    func saveFavorite(with movie: AnyMedia) {
        if let film = movie.getBaseType() as? Movie {
            favoritesRepository?.saveFavoriteMovie(film)
        }
        if let show = movie.getBaseType() as? TVShow {
            favoritesRepository?.saveFavoriteShow(show)
        }
    }
    
    func removeFavorite(with movie: AnyMedia) {
        if let film = movie.getBaseType() as? Movie {
            favoritesRepository?.removeFavoriteMovie(film)
        }
        if let show = movie.getBaseType() as? TVShow {
            favoritesRepository?.removeFavoriteShow(show)
        }
    }
    
    func retrieveFavorites() -> [Movie] {
        favoritesRepository?.getFavoriteMovies() ?? []
    }

    func isMovieInFavorites(movie: AnyMedia) -> Bool {
        
        if let film = movie.getBaseType() as? Movie {
            return favoritesRepository?.isMovieInFavorites(film) ?? false
        }
        if let show = movie.getBaseType() as? TVShow {
            return favoritesRepository?.isTvShowInFavorites(show) ?? false
        }
        
        return false
    }

}
