//
//  MediaDetailInteractor.swift
//  MovieList
//
//  Created by macbook on 15/05/2023.
//

import Foundation
// MARK: - Interactor

protocol MediaDetailInteractorProtocol: AnyObject {
    func fetchMediaDetail()
    func fetchMediaImages()
    func fetchMediaVideos()
    func fetchMediaActors()
}

class MediaDetailInteractor {
    weak var presenter: MediaDetailPresenterProtocol?
    
    // Implement the protocol methods and handle data fetching and processing
    // Use appropriate services or APIs to fetch media details, images, videos, and actors
    
    private let networkingService: NetworkingService
    
    init(networkingService: NetworkingService, presenter: MediaDetailPresenterProtocol) {
        self.networkingService = networkingService
        self.presenter = presenter
    }
}

extension MediaDetailInteractor: MediaDetailInteractorProtocol {
    func fetchMediaDetail() {
      
    }
    
    func fetchMediaImages() {
        guard let media = presenter?.media, media.id > 0 else { return }
        
        print(media)
        
        Task {
            do {
                let data = try await networkingService.getImagesForMedia(id: media.id, scope: SearchScope(media))
                let response = try JSONDecoder().decode(ImagesResponse.self, from: data)
//                let urlStrings = response.backdrops.map { $0.fullImagePath }
//                let imageDataArray = try await fetchImages(fromURLs: urlStrings)
                
                print("\n\n\n backdrop images are \(response.backdrops)")
                
                let mediaImages = response.backdrops + response.posters
                
                self.presenter?.didFinishFetchingMediaImages(mediaImages)
//                self.presenter?.didFetchMediaImages(imageDataArray)
                
            } catch let error {
                print("there was an error: \(error)")
                self.presenter?.didFetchMediaImages([])
            }
        }
    }
//
//    func fetchImages(fromURLs urls: [String]) async throws -> [Data] {
//        var imageDataArray: [Data] = []
//
//        for urlString in urls {
//            guard let url = URL(string: urlString) else {
//                throw APIError.invalidURL
//            }
//
//            do {
//                let imageData = try await networkingService.fetchImage(fromURL: url)
//                imageDataArray.append(imageData)
//            } catch {
//                // Handle individual image fetch error if needed
//            }
//        }
//
//        return imageDataArray
//    }
    
    
    func fetchMediaVideos() {
        
    }
    
    func fetchMediaActors() {
        
    }
    
    
}
