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
    static let imgBaseURL = "https://image.tmdb.org/t/p/w500"
    
    static let movieSearchPath = "/search/movie"
    static let tvSearchPath = "/search/tv"
    static let trendingMoviesPath = "/trending/movie/day"
    static let trendingTVPath = "/trending/tv/day"
    
    static let movieDetailsPath = "/movie/"
    static let tvShowDetailsPath = "/tv/"
    
}

enum MovieDBEndpoint {
    case movieSearch(query: String, page: Int)
    case tvSearch(query: String, page: Int)
    
    case trendingMovies(page: Int)
    case trendingTV(page: Int)
    
    case movieDetails(id: Int)
    case tvShowDetails(id: Int)
    
    case movieCredits(id: Int)
    case tvShowCredits(id: Int)
    
    case movieImages(id: Int)
    case tvShowImages(id: Int)
    
    case imageWithPath(filePath: String)
    
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
        case .movieDetails(id: let id):
            return ApiDict.movieDetailsPath + "\(id)"
        case .tvShowDetails(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)"
        case .movieCredits(id: let id):
            return ApiDict.movieDetailsPath + "\(id)" + "/credits"
        case .tvShowCredits(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)" + "/credits"
        case .movieImages(id: let id):
            return ApiDict.movieDetailsPath + "\(id)" + "/images"
        case .tvShowImages(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)" + "/images"
        case .imageWithPath(let filePath):
            return ApiDict.imgBaseURL + filePath
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
        case .movieDetails, .tvShowDetails, .movieCredits, .tvShowCredits, .movieImages, .tvShowImages, .imageWithPath:
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey)
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
