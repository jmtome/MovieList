//
//  UIImageView+Extension.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import UIKit

extension UIImageView {
    func loadImage(from url: String?, placeholder: UIImage? = nil) {
        guard let urlString = url,
              let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let retrImg = ImageCache.checkImage(url.absoluteString) {
                self.image = retrImg
            } else {
                
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    // Handle the response here
                    guard let data = data, error == nil else { return }
                    
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                        ImageCache.saveImage(image, for: url.absoluteString)
                    }
                }
                task.resume()
            }
        }
    }
}
