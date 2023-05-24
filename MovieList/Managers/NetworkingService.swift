//
//  NetworkingService.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

protocol NetworkingService {
    func getImagesForMedia(id: Int, scope: SearchScope) async throws -> Data
    func fetchImage(fromURL url: URL) async throws -> Data
    func searchMedia(query: String, scope: SearchScope, page: Int) async throws -> Data
}

//ver lo de page para el metodo searchMEdia
class TMDBNetworkingService {

    private let imgBase = "https://image.tmdb.org/t/p/w500/"
    ///https://image.tmdb.org/t/p/w500/l4QHerTSbMI7qgvasqxP36pqjN6.jpg
    private var page = 1
    
    //https://api.themoviedb.org/3/movie/603/images?api_key=005addb42a085a8f891a55d28223162d
            
    func getImagesForMedia(id: Int, scope: SearchScope) async throws -> Data {
        let urlString = scope == .movies ? "\(ApiDict.baseURL)movie/\(id)/images?api_key=\(ApiDict.apiKey)" : "\(ApiDict.baseURL)tv/\(id)/images?api_key=\(ApiDict.apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        print("images url is: \(url.absoluteString)")
        
        let imageData = try await fetchImage(fromURL: url)
        return imageData
    }
}

//MARK: - Networking Service Conformance
extension TMDBNetworkingService: NetworkingService {
    func searchMedia(query: String, scope: SearchScope, page: Int) async throws -> Data {
        guard !query.isEmpty else {
            return try await getTrendingMedia(page: page, searchScope: scope)
        }
        
        let searchEndpoint: MovieDBEndpoint
        switch scope {
        case .movies:
            searchEndpoint = .movieSearch(query: query, page: page)
        case .series:
            searchEndpoint = .tvSearch(query: query, page: page)
        }
        
        return try await makeNetworkCall(with: searchEndpoint)
    }

    private func getTrendingMedia(page: Int, searchScope: SearchScope) async throws -> Data {
        let endpoint: MovieDBEndpoint
        switch searchScope {
        case .movies:
            endpoint = .trendingMovies(page: page)
        case .series:
            endpoint = .trendingTV(page: page)
        }
        return try await makeNetworkCall(with: endpoint)
    }
    

    private func makeNetworkCall(with endpoint: MovieDBEndpoint) async throws -> Data {
        let urlBuilder = MovieDBURLBuilder(endpoint: endpoint)
     
        guard let url = urlBuilder.build() else {
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


