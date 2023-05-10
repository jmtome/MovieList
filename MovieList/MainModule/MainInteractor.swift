//
//  MainInteractor.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import AnyCodable


protocol MainScreenInteractorProtocol: AnyObject {
    func searchMovies(with query: String, scope: SearchScope)
   
    func saveFavorite(with movie: Movie)
    func removeFavorite(with movie: Movie)
    func isMovieInFavorites(movie: Movie) -> Bool
    
    func getPopularMovies()
    
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
    
    //have to refactor networking
    func getPopularMovies() {
        
        networkingService.getPopularMovies1 { result in
            switch result {
            case .success(let data):
                
                do {
                    let popularMoviesResponse = try JSONDecoder().decode(Response<Movie>.self, from: data)
                    let popularMovies = popularMoviesResponse.results
                    print("popular movies are: \n")
                    popularMovies.forEach { print("movie: \($0)\n")}
                    self.presenter?.didReceiveMovies(popularMovies)
                } catch let error {
                    print("the error decoding popular movies was \(error)")
                }
                
            case .failure(let error):
                break
            }
        }
        
//        networkingService.getPopularMovies { [weak self] movies, error in
//            guard let self, error == nil else { return }
//            if let movies = movies {
//                self.presenter?.didReceiveMovies(movies)
//            } else if let error = error {
//
//            }
//        }
    }
    //ver esto
    func search(with query: String, scope: SearchScope) {
        networkingService.searchMedia(query: query,
                                      scope: scope) { (result: Result<Data, APIError>) in
            
            print("\n\n\n resultType is: \(scope.resultType)")
            switch result {
            case .success(let response):
                switch scope.resultType {
                case is Movie.Type:
                    
                    do {
                        let movieResponse = try JSONDecoder().decode(Response<Movie>.self, from: response)
                        let movieList = movieResponse.results
                        self.presenter?.didReceiveMovies(movieList)
                    } catch let error {
                        print("There was an error decoding movies, error: \(error)")
                    }
                    
                    
                case is TVShow.Type:
                    do {
                        let showResponse = try JSONDecoder().decode(Response<TVShow>.self, from: response)
                        let showList = showResponse.results
//                        self.presenter?.didReceiveMovies(showList)
                    } catch let error {
                        print("There was an error decoding tv shows, error: \(error)")
                    }
                    
                    
                case is Person.Type:
                    break
                    
                default:
                    break
                }
            case .failure(let error):
                // Handle the error
                print(error)
            }
        }
    }
    
    func searchMovies(with query: String, scope: SearchScope) {
//        networkingService.searchMovies(with: query, scope: scope) { [weak self] movies, error in
//            guard let self else { return }
//            if let movies = movies {
//                self.presenter?.didReceiveMovies(movies)
//            } else if let error = error {
//                self.presenter?.didEncounterError(error)
//            }
//        }
        
        search(with: query, scope: scope)
    }
}

extension MainScreenInteractor {
    func saveFavorite(with movie: Movie) {
        favoritesRepository?.saveFavoriteMovie(movie)
    }
    
    func removeFavorite(with movie: Movie) {
        favoritesRepository?.removeFavoriteMovie(movie)
    }
    func retrieveFavorites() -> [Movie] {
        favoritesRepository?.getFavoriteMovies() ?? []
    }

    func isMovieInFavorites(movie: Movie) -> Bool {
        return favoritesRepository?.isMovieInFavorites(movie) ?? false
    }

}
