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
    
    static let nowPlayingMoviesPath = "/movie/now_playing" //#
    static let popularMoviesPath = "/movie/popular" //#
    static let topRatedMoviesPath = "/movie/top_rated" //#
    static let trendingMoviesPath = "/trending/movie/week"//#

    static let upcomingMoviesPath = "/movie/upcoming" //#

    static let nowPlayingTVPath = "/tv/on_the_air" //#
    static let popularTVPath = "/tv/popular" //#
    static let topRatedTVPath = "/tv/top_rated" //#
    static let trendingTVPath = "/trending/tv/week"//#
    
    static let airingTodayTVPath = "/tv/airing_today" //#
    
    static let movieDetailsPath = "/movie/"
    static let tvShowDetailsPath = "/tv/"
    static let personDetailsPath = "/person/"
    
}

enum MovieDBEndpoint {
    case movieSearch(query: String, page: Int)
    case tvSearch(query: String, page: Int)
    
    case nowPlayingMovies(language: String = "en-US", page: Int = 1, region: String) //now playing
    case nowPlayingTodayTV(language: String = "en-US", page: Int = 1, timezone: String) //on the air

    case popularMovies(language: String = "en-US", page: Int = 1, region: String) //popular movies
    case popularTV(language: String = "en-US", page: Int = 1) //popular tv
    
    case airingTodayTV(language: String = "en-US", page: Int = 1, timezone: String) //airing_today// tiene timezone, page y language
    case upcomingMovies(language: String = "en-US", page: Int = 1, region: String) //upcoming
    
    case topRatedMovies(language: String = "en-US", page: Int = 1, region: String) //top rated movies //tiene region, page y language
    case topRatedTV(language: String = "en-US", page: Int = 1)// top rated tv
    
    
    case trendingMovies// trending movies week
    case trendingTV// trending tv week
    
    
    case personDetails(id: Int)
    case movieDetails(id: Int)
    case tvShowDetails(id: Int)
    
    case movieCredits(id: Int)
    case tvShowCredits(id: Int)
    
    case movieStreamers(id: Int)
    case tvStreamers(id: Int)
    
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
        case .personDetails(id: let id):
            return ApiDict.personDetailsPath + "\(id)"
        case .movieDetails(id: let id):
            return ApiDict.movieDetailsPath + "\(id)"
        case .tvShowDetails(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)"
        case .movieCredits(id: let id):
            return ApiDict.movieDetailsPath + "\(id)" + "/credits"
        case .tvShowCredits(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)" + "/credits"
        case .movieStreamers(id: let id):
            return ApiDict.movieDetailsPath + "\(id)" + "/watch/providers"
        case .tvStreamers(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)" + "/watch/providers"
        case .movieImages(id: let id):
            return ApiDict.movieDetailsPath + "\(id)" + "/images"
        case .tvShowImages(id: let id):
            return ApiDict.tvShowDetailsPath + "\(id)" + "/images"
        case .imageWithPath(let filePath):
            return ApiDict.imgBaseURL + filePath
        case .nowPlayingMovies(page: let page):
            return ApiDict.nowPlayingMoviesPath
        case .nowPlayingTodayTV(page: let page):
            return ApiDict.nowPlayingTVPath
        case .popularMovies(page: let page):
            return ApiDict.popularMoviesPath
        case .popularTV(page: let page):
            return ApiDict.popularTVPath
        case .airingTodayTV(page: let page):
            return ApiDict.airingTodayTVPath
        case .topRatedMovies(page: let page):
            return ApiDict.topRatedMoviesPath
        case .topRatedTV(page: let page):
            return ApiDict.topRatedTVPath
        case .upcomingMovies(page: let page):
            return ApiDict.upcomingMoviesPath
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
        case .trendingMovies,
             .trendingTV:
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
            ]
        case .movieDetails, .tvShowDetails:
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "append_to_response", value: "videos")

            ]
        case .movieCredits, .tvShowCredits, .movieImages, .tvShowImages, .imageWithPath, .movieStreamers, .tvStreamers:
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey)
            ]
        case .personDetails:
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "append_to_response", value: "movie_credits,images")
            ]
        case .nowPlayingMovies(language: let language, page: let page, region: let region):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .nowPlayingTodayTV(language: let language, page: let page, timezone: let timezone):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .popularMovies(language: let language, page: let page, region: let region):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .popularTV(language: let language, page: let page):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .airingTodayTV(language: let language, page: let page, timezone: let timezone):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .topRatedMovies(language: let language, page: let page, region: let region):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .topRatedTV(language: let language, page: let page):
            return [
                URLQueryItem(name: "api_key", value: ApiDict.apiKey),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .upcomingMovies(language: let language, page: let page, region: let region):
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
