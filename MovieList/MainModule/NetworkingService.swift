//
//  NetworkingService.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation
import AnyCodable

enum APIError: Error {
    case networkError(Error)
    case apiError(Int, String)
    case invalidResponse
    case decodingError(Error)
    case invalidURL
}
protocol NetworkingService {
    func searchMovies(with query: String, scope: SearchScope, completion: @escaping ([Movie]?, Error?) -> Void)
    func getPopularMovies(completion: @escaping ([Movie]?, Error?) -> Void)
    
//    func searchMedia<T: Codable>(query: String,
//                                 scope: SearchScope,
//                                 completion: @escaping (Result<Response<T>, APIError>) -> Void)
    func searchMedia(query: String,
                                 scope: SearchScope,
                                 completion: @escaping (Result<Data, APIError>) -> Void)
    
    func getPopularMovies1(completion: @escaping (Result<Data, APIError>) -> Void)
}

class TMDBNetworkingService: NetworkingService {
    private let apiKey = "005addb42a085a8f891a55d28223162d"
    private let baseURL = "https://api.themoviedb.org/3"
    private let imgBase = "https://image.tmdb.org/t/p/w500/"
    private lazy var popMovsUrlString = "\(baseURL)/movie/popular?api_key=\(apiKey)"

    private let decoder = JSONDecoder()
    // /movie/popular?api_key=YOUR_API_KEY_HERE

    init() {
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    //  https://api.themoviedb.org/3/search/movie?api_key=005addb42a085a8f891a55d28223162d&language=en-US&page=1&include_adult=false
    
    func getPopularMovies1(completion: @escaping (Result<Data, APIError>) -> Void) {
        guard let url = URL(string: popMovsUrlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    func getPopularMovies(completion: @escaping ([Movie]?, Error?) -> Void) {
//        let popMovsUrlString = "\(baseURL)/movie/popular?api_key=\(apiKey)"
        guard let url = URL(string: popMovsUrlString) else {
            completion(nil, NetworkingError.invalidURL)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(nil, NetworkingError.noData)
                }
                return
            }
            
            do {
                let response = try self.decoder.decode(SearchResponse.self, from: data)
                let movies = response.results
                completion(movies, nil)
            } catch {
                completion(nil, NetworkingError.invalidResponse)
            }
        }
        
        task.resume()
    }
    
    func searchMovies(with query: String, scope: SearchScope, completion: @escaping ([Movie]?, Error?) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil, NetworkingError.invalidQuery)
            return
        }
        
        let urlString = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkingError.invalidURL)
            return
        }
                
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkingError.noData)
                return
            }
            
            do {
//                let decoder = JSONDecoder()
//                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try self.decoder.decode(SearchResponse.self, from: data)
                let movies = response.results
//                movies.forEach { print("Release date: \($0.releaseDate)") }
                completion(movies, nil)
            } catch {
                completion(nil, NetworkingError.invalidResponse)
            }
        }
        
        task.resume()
        
    }
    
    func fetchImage(fromURL url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
          URLSession.shared.dataTask(with: url) { data, response, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              
              guard let data = data else {
                  completion(.failure(NetworkingError.invalidData))
                  return
              }
              
              completion(.success(data))
          }.resume()
      }
}

enum NetworkingError: Error {
    case invalidQuery
    case invalidURL
    case noData
    case invalidResponse
    case invalidData
}

struct SearchResponse: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]
}



extension TMDBNetworkingService {

//
//    func searchMedia<T: Codable>(query: String,
//                                 scope: SearchScope,
//                                 completion: @escaping (Result<Response<T>, APIError>) -> Void) {
    
    func searchMedia(query: String,
                                 scope: SearchScope,
                                 completion: @escaping (Result<Data, APIError>) -> Void) {
        let apiKey = "005addb42a085a8f891a55d28223162d"
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchURL: String
        
        let resultType: Codable.Type = scope.resultType
        switch scope {
        case .movies:
            searchURL = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(searchQuery)"
        case .series:
            searchURL = "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&query=\(searchQuery)"
        case .actors:
            searchURL = "https://api.themoviedb.org/3/search/person?api_key=\(apiKey)&query=\(searchQuery)"
        case .directors:
            searchURL = "https://api.themoviedb.org/3/search/person?api_key=\(apiKey)&query=\(searchQuery)&department=Directing"
        }
        
        guard let url = URL(string: searchURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                completion(.failure(.networkError(error!)))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            completion(.success(data))
//            do {
//                let result = try self.decoder.decode(Response<Movie>.self, from: data)
//                let movieList = result.results
//                completion(.success(movieList))
//            } catch {
//                completion(.failure(.decodingError(error)))
//            }
            
//            do {
//                let searchResult = try JSONDecoder().decode(Response<T>.self, from: data)
////                let mediaList = searchResult.results.map { Media(from: $0) }
////                let mediaList: [Media] = []
//                completion(.success(searchResult))
//            } catch let error {
//                completion(.failure(.decodingError(error)))
//            }
        }.resume()
    }

    /*
     let decoder = JSONDecoder()

     // Decode PersonResponse
     let personResponse = try decoder.decode(Response<PersonResponse>.self, from: json)

     // Decode MovieResponse
     let movieResponse = try decoder.decode(Response<MovieResponse>.self, from: json)

     // Decode TVShowResponse
     let tvShowResponse = try decoder.decode(Response<TVShowResponse>.self, from: json)
     */

    
    struct SearchResult: Codable {
        let results: [SearchResultItem]
    }

    struct SearchResultItem: Codable {
        let title: String?
        let name: String?
        let releaseDate: String?
        let firstAirDate: String?
        let popularity: Double
        let voteAverage: Double?
    }
    
}
