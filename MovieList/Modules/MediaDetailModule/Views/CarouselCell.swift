//
//  CarouselCell.swift
//  MovieList
//
//  Created by macbook on 16/05/2023.
//

import UIKit

// Custom cell
class CarouselCell: UICollectionViewCell {
    var imageView: UIImageView!
    
    let tmdbLogo: UIImage = UIImage(named: "tmdbLogo_long")!
    let placeholder: UIImage = UIImage(systemName: "photo")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the image view
        imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
        imageView.image = placeholder
        
        // Add the image view to the cell's content view
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
    }
    
    func setup(_ media: MediaImage) {
        activityStartAnimating(activityColor: .white, backgroundColor: .softDark)
        imageView.loadImage(from: media.fullImagePath, placeholder: tmdbLogo) {
            DispatchQueue.mainAsyncIfNeeded {
                self.activityStopAnimating()                
            }
        }
        
//        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
