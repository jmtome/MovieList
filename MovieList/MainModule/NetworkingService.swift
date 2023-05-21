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
//    func searchMedia(query: String,
//                     scope: SearchScope,
//                     page: Int,
//                     completion: @escaping (Result<Data, APIError>) -> Void)
  
    func searchMedia(query: String, scope: SearchScope, page: Int) async throws -> Data
    
    func getPopularMedia(scope: SearchScope, page: Int) async throws -> Data
    
    func getImagesForMedia(id: Int, scope: SearchScope) async throws -> Data
    func fetchImage(fromURL url: URL) async throws -> Data
}

//ver lo de page para el metodo searchMEdia
class TMDBNetworkingService: NetworkingService {

    private let apiKey = "005addb42a085a8f891a55d28223162d"
    private let baseURL = "https://api.themoviedb.org/3/"
    private let imgBase = "https://image.tmdb.org/t/p/w500/"
    ///https://image.tmdb.org/t/p/w500/l4QHerTSbMI7qgvasqxP36pqjN6.jpg
    private var page = 1
    
    private lazy var popMovsUrlString = "\(baseURL)movie/popular?api_key=\(apiKey)&page="
    private lazy var popShowsUrlString = "\(baseURL)tv/popular?api_key=\(apiKey)&page="
    
    //https://api.themoviedb.org/3/movie/603/images?api_key=005addb42a085a8f891a55d28223162d
    
    private let decoder = JSONDecoder()
        
    func getImagesForMedia(id: Int, scope: SearchScope) async throws -> Data {
//        let urlString = "\(baseURL)\(scope.urlAppendix)/\(id)/images?api_key=\(apiKey)"
        let urlStrin = "\(baseURL)movie/\(id)/images?api_key=\(apiKey)"
        let urlString = scope == .movies ? "\(baseURL)movie/\(id)/images?api_key=\(apiKey)" : "\(baseURL)tv/\(id)/images?api_key=\(apiKey)"
        
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        print("images url is: \(url.absoluteString)")
        
        let imageData = try await fetchImage(fromURL: url)
        return imageData
    }
    
    
    func getPopularMedia(scope: SearchScope = .movies, page: Int) async throws -> Data {
        self.page = page
        
        guard let url = URL(string: scope == .movies ? "\(popMovsUrlString)\(page)" : "\(popShowsUrlString)\(page)") else {
            throw APIError.invalidURL
        }
        
        print("url is: \(url.absoluteString)")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return data
    }
    

}
extension TMDBNetworkingService {
    func searchMedia(query: String, scope: SearchScope, page: Int) async throws -> Data {
        let apiKey = "005addb42a085a8f891a55d28223162d"
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var searchURL: String = ApiDict.baseURL + "search/"
        
        switch scope {
        case .movies:
            searchURL = "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
        case .series:
            searchURL = "https://api.themoviedb.org/3/search/tv?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
        case .actors:
            searchURL = "https://api.themoviedb.org/3/search/person?api_key=\(apiKey)&query=\(searchQuery)&page=\(page)"
        }
        
        print("url for search media is: \(searchURL)")
        guard let url = URL(string: searchURL) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return data
    }

}

// I think this may belong here, but right now im calling it on the cell, (not good, breaks viper)
extension TMDBNetworkingService {

    func fetchImage(fromURL url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return data
    }
    
}
