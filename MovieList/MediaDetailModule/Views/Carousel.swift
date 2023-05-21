//
//  Carousel.swift
//  MovieList
//
//  Created by macbook on 17/05/2023.
//

import UIKit

class Carousel: UIView {

    private var collectionView: UICollectionView!
    private var mediaImages: [MediaImage] = []
    private var superView: UIView!
    
    let dummyImages: [MediaImage] = [
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png", voteAverage: 0, voteCount: 0, width: 0),
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/2.png", voteAverage: 0, voteCount: 0, width: 0),
        MediaImage(aspectRatio: 0, height: 0, iso639_1: nil, filePath: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/3.png", voteAverage: 0, voteCount: 0, width: 0)
    ]
    
    init(frame: CGRect, media: [MediaImage], in view: UIView) {
        super.init(frame: frame)
        self.superView = view
        if media.isEmpty {
            self.mediaImages = dummyImages
        } else {
            self.mediaImages = media            
        }
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDataSource(with media: [MediaImage]) {
        self.mediaImages = media
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func setupCollectionView() {

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: self.superView))
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)

        self.backgroundColor = .blue
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        collectionView.collectionViewLayout = UIHelper.createThreeColumnFlowLayout(in: self.superView)
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast // Adjust scroll deceleration rate for smoother transitions
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemTeal
        self.backgroundColor = .blue
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        
    }

}

extension Carousel: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mediaImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! CarouselCell
        let media = mediaImages[indexPath.item]
        
        print("\n\n\n\nmedia image is: \(media.fullImagePath)")
        print("\n\n media is:\(media)")
        cell.setup(media)
        return cell
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.collectionView.scrollToNearestVisibleCollectionViewCell()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.collectionView.scrollToNearestVisibleCollectionViewCell()
        }
    }

}
