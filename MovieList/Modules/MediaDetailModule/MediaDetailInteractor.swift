//
//  MediaDetailInteractor.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import Foundation
// MARK: - Interactor


protocol MediaDetailInteractorOutputProtocol: AnyObject {
    func didReceiveMediaStreamingDetails(providers: CountryWatchProviders?)
    func didReceiveMediaDetails(_ media: MediaViewModel)
    func didReceiveMediaCredits(_ credits: MediaCredits)
    func didReceiveMediaImages(backdrops: [MediaImage], posters: [MediaImage])
    func didReceiveError(_ error: Error)
}

// called by presenter, implemented by interactor
protocol MediaDetailInteractorInputProtocol: AnyObject {
    func fetchMediaImages(for mediaTypeId: MediaTypeID)
    func fetchMediaCredits(for mediaTypeId: MediaTypeID)
    func fetchMediaDetails(for mediaTypeId: MediaTypeID)
    func fetchMediaStreamers(for mediaTypeId: MediaTypeID)
}

//Called by Presenter, Implemented by MediaDetailFavoritesInteractor
protocol MediaDetailInteractorFavoriteInputProtocol: AnyObject {
    func isMovieInFavorites(media: MediaViewModel) -> Bool
    func handleFavoriteAction(for media: MediaViewModel)
}

protocol MediaDetailFavoriteOutputProtocol: AnyObject {
    func presentMediaRemovedFromFavorites()
    func presentMediaAddedToFavorites()
}

class MediaDetailFavoritesInteractor {
    private var favoritesRepository: FavoritesRepository
    weak var output: MediaDetailFavoriteOutputProtocol?
    
    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }
}

extension MediaDetailFavoritesInteractor: MediaDetailInteractorFavoriteInputProtocol {
    func handleFavoriteAction(for media: MediaViewModel) {
        if isMovieInFavorites(media: media) {
            favoritesRepository.removeFavorite(media: media)
            output?.presentMediaRemovedFromFavorites()
        } else {
            favoritesRepository.saveFavorite(media: media)
            output?.presentMediaAddedToFavorites()
        }
    }
    func isMovieInFavorites(media: MediaViewModel) -> Bool {
        favoritesRepository.isMediaInFavorites(media: media)
    }
    
}

class MediaDetailInteractor {
    weak var output: MediaDetailInteractorOutputProtocol?
    
    private let networkingService: NetworkingService
    
    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }
}

extension MediaDetailInteractor: MediaDetailInteractorInputProtocol {
    func fetchMediaCredits(for mediaTypeId: MediaTypeID) {
        Task {
            var credits: MediaCredits
            do {
                let mediaCreditsData = try await networkingService.getMediaCredits(for: mediaTypeId)
                credits = try JSONDecoder().decode(MediaCredits.self, from: mediaCreditsData)
                output?.didReceiveMediaCredits(credits)
            } catch let error {
                print("there was an error fetching media credits for media id: \(mediaTypeId.id), with error: \(error)")
            }
        }
    }
    
    func fetchMediaDetails(for mediaTypeId: MediaTypeID) {
        
        Task {
            var viewModel: MediaViewModel
            do {
                let mediaDetailsData = try await networkingService.getMediaDetails(for: mediaTypeId)
                switch mediaTypeId.type {
                case .movie:
                    let moviesDetailResponse = try JSONDecoder().decode(Movie.self, from: mediaDetailsData)
                    viewModel = MediaViewModel(movie: moviesDetailResponse)
                    output?.didReceiveMediaDetails(viewModel)
                case .tvshow:
                    let seriesDetailResponse = try JSONDecoder().decode(TVShow.self, from: mediaDetailsData)
                    viewModel = MediaViewModel(tvshow: seriesDetailResponse)
                    output?.didReceiveMediaDetails(viewModel)
                }
            } catch let error {
                print("There was an error caught trying to fetch the MediaDetails for mediaTypeId: \(mediaTypeId)\n error: \(error)")
                output?.didReceiveError(error)
            }
        }
    }
    
    func fetchMediaStreamers(for mediaTypeId: MediaTypeID) {
        Task {
            do {
                let streamingServicesData = try await networkingService.getMediaStreamers(for: mediaTypeId)
                let response = try JSONDecoder().decode(WatchProviderResponse.self, from: streamingServicesData)
                
                let providers = response.getProviders()
                
                output?.didReceiveMediaStreamingDetails(providers: providers)
                
            } catch let error {
                print("There was an error caught trying to fetch the MediaDetails for mediaTypeId: \(mediaTypeId)\n error: \(error)")
                output?.didReceiveError(error)
            }
        }
    }
    
    func fetchMediaImages(for mediaTypeId: MediaTypeID) {
        Task {
            do {
                let mediaImagesData = try await networkingService.getImagesForMedia(for: mediaTypeId)
                let response = try JSONDecoder().decode(ImagesResponse.self, from: mediaImagesData)
                
                let backdrops = response.backdrops.sorted { (0.6 * Double($0.voteCount) + 0.4 * $0.voteAverage) > (0.6 * Double($1.voteCount) + 0.4 * $1.voteAverage) }
                let posters = response.posters.sorted { (0.6 * Double($0.voteCount) + 0.4 * $0.voteAverage) > (0.6 * Double($1.voteCount) + 0.4 * $1.voteAverage) }
                
                output?.didReceiveMediaImages(backdrops: backdrops, posters: posters)
            } catch let error {
                print("There was an error caught trying to fetch the MediaImages for mediaTypeId: \(mediaTypeId)\n error: \(error)")
                output?.didReceiveError(error)
            }
        }
    }
    
}
