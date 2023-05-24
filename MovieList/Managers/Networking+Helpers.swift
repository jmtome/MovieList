//
//  Networking+Helpers.swift
//  MovieList
//
//  Created by macbook on 23/05/2023.
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

enum ApiDict {
    static let apiKey = "005addb42a085a8f891a55d28223162d"
    
    static let baseURL = "https://api.themoviedb.org/3"
    static let imgBaseURL = "https://image.tmdb.org/t/p/w500/"
    
    static let movieSearchPath = "/search/movie"
    static let tvSearchPath = "/search/tv"
    static let trendingMoviesPath = "/trending/movie/day"
    static let trendingTVPath = "/trending/tv/day"
}

enum MovieDBEndpoint {
    case movieSearch(query: String, page: Int)
    case tvSearch(query: String, page: Int)
    case trendingMovies(page: Int)
    case trendingTV(page: Int)
    
    var baseURL: URL {
        return URL(string: ApiDict.baseURL)!
    }
    
    var path: String {
        switch self {
        case .movieSearch:
            return ApiDict.movieSearchPath
        case .tvSearch:
            return ApiDict.tvSearchPath
        case .trendingMovies:
            return ApiDict.trendingMoviesPath
        case .trendingTV:
            return ApiDict.trendingTVPath
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .movieSearch(let query, let page),
             .tvSearch(let query, let page):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .trendingMovies(let page),
             .trendingTV(let page):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
    }
}

struct MovieDBURLBuilder {
    private var endpoint: MovieDBEndpoint
    
    init(endpoint: MovieDBEndpoint) {
        self.endpoint = endpoint
    }
    
    func build() -> URL? {
        var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true)
        components?.queryItems = endpoint.queryItems
        return components?.url
    }
}
