//
//  FavoritesInteractor.swift
//  MovieList
//
//  Created by macbook on 23/05/2023.
//

import Foundation

protocol FavoritesScreenInteractorInputProtocol: AnyObject {
    func getFavoriteMedia(for type: MediaType)
    func getFavoriteMedia(for type: MediaType, matching query: String)
    
    func isMovieInFavorites(media: MediaViewModel) -> Bool
    func handleFavoriteAction(with media: MediaViewModel)
}

protocol FavoritesScreenInteractorOutputProtocol: AnyObject {
    func presentMediaRemovedFromFavorites()
    func didReceiveFavoriteMedia(_ media: [MediaViewModel])
}

//MARK: - MainScreenInteractor
class FavoritesScreenInteractor {
    private let favoritesRepository: FavoritesRepository
        
    weak var output: FavoritesScreenInteractorOutputProtocol?
    
    init(favoritesRepository: FavoritesRepository) {
        self.favoritesRepository = favoritesRepository
    }
}

extension FavoritesScreenInteractor: FavoritesScreenInteractorInputProtocol {
    func getFavoriteMedia(for type: MediaType, matching query: String) {
        let favoriteMedia = favoritesRepository.getFavoriteMedia(for: type)
        
        let filteredVM = favoriteMedia.filter { media in
            let titleWords = media.title.split(separator: " ")
            return titleWords.contains { word in
                word.hasPrefix(query)
            }
        }
        
        output?.didReceiveFavoriteMedia(filteredVM)
    }
    
    func getFavoriteMedia(for type: MediaType) {
        let favoriteMedia = favoritesRepository.getFavoriteMedia(for: type)
        output?.didReceiveFavoriteMedia(favoriteMedia)
    }
    
    func isMovieInFavorites(media: MediaViewModel) -> Bool {
        true
    }
    
    func handleFavoriteAction(with media: MediaViewModel) {
        if isMovieInFavorites(media: media) {
            favoritesRepository.removeFavorite(media: media)
            output?.presentMediaRemovedFromFavorites()
        }
    }
    
    
}
