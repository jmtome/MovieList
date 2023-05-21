//
//  UIKit+Extension.swift
//  MovieList
//
//  Created by macbook on 17/05/2023.
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

extension UICollectionView {
    func scrollToNearestVisibleCollectionViewCell() {
        self.decelerationRate = UIScrollView.DecelerationRate.fast
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)

            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}

enum UIHelper {
    
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width   = view.bounds.width
        let padding: CGFloat = 0
        let minimumItemSpacing: CGFloat = 2
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 1
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: 180)
        flowLayout.scrollDirection = .horizontal
        
        return flowLayout
    }
}


extension DispatchQueue {
    static func mainAsyncIfNeeded(execute work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            main.async(execute: work)
        }
    }
}
