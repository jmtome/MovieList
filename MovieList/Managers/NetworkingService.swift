//
//  NetworkingService.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import Foundation

protocol NetworkingService {
    func fetchImage(from path: String) async throws -> Data
    func searchMedia(query: String, scope: SearchScope, page: Int) async throws -> Data
    
    func getMediaDetails(for mediaTypeId: MediaTypeID) async throws -> Data
    func getMediaCredits(for mediaTypeId: MediaTypeID) async throws -> Data
    func getMediaStreamers(for mediaTypeId: MediaTypeID) async throws -> Data
    func getImagesForMedia(for mediaTypeId: MediaTypeID) async throws -> Data
    func getActorDetails(for actorId: Int) async throws -> Data
}

//ver lo de page para el metodo searchMEdia
class TMDBNetworkingService {

    private let imgBase = "https://image.tmdb.org/t/p/w500/"
    ///https://image.tmdb.org/t/p/w500/l4QHerTSbMI7qgvasqxP36pqjN6.jpg
    ///https://image.tmdb.org/t/p/w500/khveUylm0fqlLGuUHLg74tKozdy.jpg
    private var page = 1
    
    //https://api.themoviedb.org/3/movie/603/images?api_key=005addb42a085a8f891a55d28223162d
            
    func fetchImage(from path: String) async throws -> Data {
        let imageEndpoint: MovieDBEndpoint = .imageWithPath(filePath: path)
        
        return try await makeNetworkCall(with: imageEndpoint)
    }
    
    func getMediaDetails(for mediaTypeId: MediaTypeID) async throws -> Data {
        let mediaDetailsEndpoint: MovieDBEndpoint
        
        switch mediaTypeId.type {
        case .movie:
            mediaDetailsEndpoint = .movieDetails(id: mediaTypeId.id)
        case .tvshow:
            mediaDetailsEndpoint = .tvShowDetails(id: mediaTypeId.id)
        }
        
        return try await makeNetworkCall(with: mediaDetailsEndpoint)
    }
    
    func getMediaCredits(for mediaTypeId: MediaTypeID) async throws -> Data {
        let mediaCreditsEndpoint: MovieDBEndpoint
        
        switch mediaTypeId.type {
        case .movie:
            mediaCreditsEndpoint = .movieCredits(id: mediaTypeId.id)
        case .tvshow:
            mediaCreditsEndpoint = .tvShowCredits(id: mediaTypeId.id)
        }
        
        return try await makeNetworkCall(with: mediaCreditsEndpoint)
    }
    
    func getMediaStreamers(for mediaTypeId: MediaTypeID) async throws -> Data {
        let mediaStreamersEndpoint: MovieDBEndpoint
        
        switch mediaTypeId.type {
        case .movie:
            mediaStreamersEndpoint = .movieStreamers(id: mediaTypeId.id)
        case .tvshow:
            mediaStreamersEndpoint = .tvStreamers(id: mediaTypeId.id)
        }
        
        return try await makeNetworkCall(with: mediaStreamersEndpoint)
    }
    
    func getActorDetails(for actorId: Int) async throws -> Data {
        let actorDetailsEndpoint: MovieDBEndpoint = .personDetails(id: actorId)
        
        return try await makeNetworkCall(with: actorDetailsEndpoint)
    }
    
    func getImagesForMedia(for mediaTypeId: MediaTypeID) async throws -> Data {
        let mediaImagesEndpoint: MovieDBEndpoint
        
        switch mediaTypeId.type {
            
        case .movie:
            mediaImagesEndpoint = .movieImages(id: mediaTypeId.id)
        case .tvshow:
            mediaImagesEndpoint = .tvShowImages(id: mediaTypeId.id)
        }
        
        return try await makeNetworkCall(with: mediaImagesEndpoint)
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


