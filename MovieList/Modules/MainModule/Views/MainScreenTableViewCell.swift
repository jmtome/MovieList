//
//  MainScreenTableViewCell.swift
//  MovieList
//
//  Created by macbook on 03/05/2023.
//

import UIKit

class MainScreenTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "MainScreenTableViewCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 2
        label.textColor = .label
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "popcorn")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        label.textColor = .gray
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 1
        label.textColor = .gray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .caption1)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .label
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        posterImageView.image = UIImage(systemName: "popcorn")
        ratingLabel.text = ""
        dateLabel.text = ""
        descriptionLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let button = actionButton {
            button.setTitleColor(.secondaryLabel, for: .normal)
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        if let button = actionButton {
            button.setTitleColor(.secondaryLabel, for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    
    
    private func setupViews() {
        // Add subviews
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(posterImageView)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(descriptionLabel)
        
        // Configure constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            posterImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            posterImageView.widthAnchor.constraint(equalToConstant: 80),
            posterImageView.heightAnchor.constraint(equalToConstant: 120),
            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),

            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            
        ])
        
        containerView.backgroundColor = .systemFill
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        posterImageView.layer.cornerRadius = 10
        posterImageView.layer.masksToBounds = true
        
        backgroundColor = .softDark
    }
    
    func setup(with media: MediaViewModel) {
        titleLabel.text = media.title
        descriptionLabel.text = media.description
        ratingLabel.text = media.getStarRating()
        dateLabel.text = media.dateAired
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            isShimmering = true
        }
        posterImageView.loadImage(from: media.mainPosterURLString, placeholder: UIImage(systemName: "popcorn")) { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                isShimmering = false
            }
        }
    }
}
