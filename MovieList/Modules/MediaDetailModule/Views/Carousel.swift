//
//  Carousel.swift
//  MovieList
//
//  Created by macbook on 17/05/2023.
//

import UIKit

class Carousel: UIView {

    private var collectionView: UICollectionView!
    private var backdrops: [MediaImage] = []
    private var superView: UIView!
    
    init(frame: CGRect, backdrops: [MediaImage], in view: UIView) {
        super.init(frame: frame)
        self.superView = view
        self.backdrops = backdrops
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDataSource(with media: MediaViewModel?) {
        guard let media = media else { return }
        self.backdrops = media.backdrops
        DispatchQueue.mainAsyncIfNeeded {
            self.overlayLogoView.setup(with: media)
            self.collectionView.reloadData()
        }
    }
    
    func updateDataSource(with backdrops: [MediaImage]) {
        self.backdrops = backdrops
        DispatchQueue.mainAsyncIfNeeded {
            self.collectionView.reloadData()
        }
    }
    
    let overlayLogoView = OverlayLogoView(frame: .zero)
    
    private func setupCollectionView() {
        // Create and configure the collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: calculateHorizontalInset(), bottom: 0, right: calculateHorizontalInset())
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: superView.bounds.width, height: 180)
        
        // Create the collection view with the calculated layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        // Register your cell class or nib file
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
        
        // Add the collection view to your view controller's view
        addSubview(collectionView)
        addSubview(overlayLogoView)
        
        overlayLogoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overlayLogoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            overlayLogoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        collectionView.backgroundColor = .softDark
        
        // Set up constraints for the collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    // Helper method to calculate the horizontal inset to center the cells
    private func calculateHorizontalInset() -> CGFloat {
        let cellWidth: CGFloat = superView.bounds.width // Assuming each cell takes the full width of the screen
        let numberOfCells = 1
        let totalCellsWidth = cellWidth * CGFloat(numberOfCells)
        let horizontalInset = (self.superView.bounds.width - totalCellsWidth) / 2
        print("horizontal offset: \(horizontalInset)")
        return max(horizontalInset, 0)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//            // Return the desired size for your cells
//            return CGSize(width: superView.bounds.width, height: 180)
//        }
    
    /*
     override func viewDidLayoutSubviews() {
             super.viewDidLayoutSubviews()
             
             // Update the section inset of the collection view layout to center the cells
             let inset = calculateHorizontalInset()
             collectionView.collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
         }
     */
    
//    private func setupCollectionView() {
//
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: self.superView))
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(collectionView)
//
//        self.backgroundColor = .blue
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
//            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
//            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            collectionView.heightAnchor.constraint(equalToConstant: 180)
//        ])
//
//        collectionView.collectionViewLayout = UIHelper.createThreeColumnFlowLayout(in: self.superView)
//        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast // Adjust scroll deceleration rate for smoother transitions
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.backgroundColor = .systemTeal
//        self.backgroundColor = .blue
//        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: "CarouselCell")
//        collectionView.isPagingEnabled = true
//
//    }

}

extension Carousel: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        backdrops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselCell", for: indexPath) as! CarouselCell
        let media = backdrops[indexPath.item]
        
        print("\n\n\n\nmedia image is: \(media.fullImagePath)")
        print("\n\n media is:\(media)")
        cell.setup(media)
        return cell
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.collectionView.scrollToNearestVisibleCollectionViewCell()
//        snapToNearestCell(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            self.collectionView.scrollToNearestVisibleCollectionViewCell()
//        }
//        snapToNearestCell(scrollView: scrollView)
    }

    
    func snapToNearestCell(scrollView: UIScrollView) {
         let middlePoint = Int(scrollView.contentOffset.x + UIScreen.main.bounds.width / 2)
         if let indexPath = self.collectionView.indexPathForItem(at: CGPoint(x: middlePoint, y: 0)) {
              self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
         }
    }
}
