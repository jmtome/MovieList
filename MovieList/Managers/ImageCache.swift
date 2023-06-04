//
//  ImageCache.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import UIKit

final class ImageCache {
    static let cache = NSCache<NSString, UIImage>()
    
    static func checkImage(_ imageString: String) -> UIImage? {
        let cacheKey = NSString(string: imageString)
        if let image = cache.object(forKey: cacheKey) {
            return image
        } else {
            return nil
        }
    }
    
    static func saveImage(_ image: UIImage, for imageString: String) {
        let cacheKey = NSString(string: imageString)
        cache.setObject(image, forKey: cacheKey)
    }
}

final class MediaEntryWrapper {
    let value: MediaViewModel
    let expirationDate: Date
    
    init(value: MediaViewModel, expirationDate: Date) {
        self.value = value
        self.expirationDate = expirationDate
    }
    
}

//final class Cache<Key: Hashable, Value> {
//    private let wrapped = NSCache<WrappedKey, Entry>()
//}
//
//final class PopularMediaCache {
//    static let cache = NSCache<NSString, MediaEntryWrapper>()
//    
//    
//}
