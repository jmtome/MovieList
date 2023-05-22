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
    
    let placeholder: UIImage = UIImage(systemName: "photo.fill.on.rectangle.fill")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the image view
        imageView = UIImageView(frame: contentView.bounds)
        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "person")
        
        // Add the image view to the cell's content view
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
//        imageView.layer.cornerRadius = 110
//        imageView.layer.masksToBounds = true
        
        
//        contentView.layer.cornerRadius = 40
//        contentView.layer.masksToBounds = true
//        contentView.layer.borderWidth = 2
//        contentView.layer.borderColor = UIColor.black.cgColor

        
    }
    
    func setup(_ media: MediaImage) {
        guard let url = URL(string: media.fullImagePath) else {
            imageView.image = placeholder
            return
        }
        imageView.loadImage(from: url.absoluteString, placeholder: placeholder)
        
        contentView.layer.cornerRadius = 40
        contentView.clipsToBounds = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
