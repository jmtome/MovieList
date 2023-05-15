//
//  NetworkingService.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

enum APIError: Error {
    case networkError(Error)
    case apiError(Int, String)
    case invalidResponse
    case decodingError(Error)
    case invalidURL
    case invalidData
}

struct ApiDict {
    static let apiKey = "005addb42a085a8f891a55d28223162d"
    
    static let baseURL = "https://api.themoviedb.org/3"
    static let imgBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    static let popularShowsURL = "\(baseURL)/tv/popular?api_key=\(apiKey)"
    static let popularMoviesURL = "\(baseURL)/movie/popular?api_key=\(apiKey)"
    
}

protocol NetworkingService {
    func searchMedia(query: String,
                     scope: SearchScope,
                     page: Int,
                     completion: @escaping (Result<Data, APIError>) -> Void)
    
    func getPopularMedia(scope: SearchScope, page: Int, completion: @escaping (Result<Data, APIError>) -> Void)
}

//ver lo de page para el metodo searchMEdia
class TMDBNetworkingService: NetworkingService {
    private let apiKey = "005addb42a085a8f891a55d28223162d"
    private let baseURL = "https://api.themoviedb.org/3/"
    private let imgBase = "https://image.tmdb.org/t/p/w500/"
    private var page = 1
    
    private lazy var popMovsUrlString = "\(baseURL)movie/popular?api_key=\(apiKey)&page="
    private lazy var popShowsUrlString = "\(baseURL)tv/popular?api_key=\(apiKey)&page="
    
    private let decoder = JSONDecoder()
        
    func getPopularMedia(scope: SearchScope = .movies, page: Int, completion: @escaping (Result<Data, APIError>) -> Void) {
        self.page = page
        guard let url = URL(string: scope == .movies ? "\(popMovsUrlString)\(page)" : "\(popShowsUrlString)\(page)") else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("url is: \(url.absoluteString)")
        
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
}
extension TMDBNetworkingService {
    func searchMedia(query: String,
                     scope: SearchScope,
                     page: Int,
                     completion: @escaping (Result<Data, APIError>) -> Void) {
        let apiKey = "005addb42a085a8f891a55d28223162d"
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var searchURL: String = ApiDict.baseURL + "search/"
        
        
        
//        var queryURL: String = ApiDict.baseURL + "search/" + "\(scope.urlAppendix)?" + "api_key\(ApiDict.apiKey)" + "&" + "query=\(search)"
        
        
        switch scope {
        case .movies:
            searchURL = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
        case .series:
            searchURL = "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
        case .actors:
            searchURL = "https://api.themoviedb.org/3/search/person?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
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
        }.resume()
    }
}

// I think this may belong here, but right now im calling it on the cell, (not good, breaks viper)
extension TMDBNetworkingService {
    func fetchImage(fromURL url: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(APIError.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
}
