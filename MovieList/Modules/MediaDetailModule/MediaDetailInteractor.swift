//
//  MediaDetailInteractor.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import Foundation
// MARK: - Interactor


protocol MediaDetailInteractorOutputProtocol: AnyObject {
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
