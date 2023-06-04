//
//  MediaInfoView.swift
//  MovieList
//
//  Created by macbook on 17/05/2023.
//

import UIKit


/*
 
 */

class TitleAndOverview: UIView {
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        backgroundColor = .prussianBlue
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
//        activityStartAnimating(activityColor: .white, backgroundColor: .softDark)
        //como esta vista no tiene un tamanio minimo, el spinner no se ve en el medio,
    }
    
    func setup(with media: MediaViewModel?) {
        guard let media = media else { return }
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            guard let self = self else { return }
            titleLabel.text = media.title
            descriptionLabel.text = media.description
//            activityStopAnimating()
        }
    }
    
}

class MediaInfoView: UIView {

    let ratingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Rating:"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let ratingValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .subheadline)
        
        label.textColor = .lightGray
        return label
    }()
    
    let runtimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Runtime:"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let runtimeValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .subheadline)
        
        label.textColor = .lightGray
        return label
    }()
    
    let genresLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Genre:"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let genresValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 2
        label.textColor = .lightGray
        return label
    }()
    
    let directorLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Director:"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let directorValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 3
        label.textColor = .lightGray
        return label
    }()
    
    lazy var verticalLabelStackView: UIStackView  = {
        let stackview = UIStackView(arrangedSubviews: [ratingLabel,
                                                       genresLabel,
                                                       runtimeLabel,
                                                       directorLabel])
        stackview.axis = .vertical
        stackview.spacing = 8
        stackview.distribution = .fillEqually
        stackview.translatesAutoresizingMaskIntoConstraints = false

        return stackview
    }()
    
    lazy var verticalValuesStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [ratingValue,
                                                       genresValue,
                                                       runtimeValue,
                                                       directorValue])
        stackview.axis = .vertical
        stackview.spacing = 8
        stackview.distribution = .fillEqually
        stackview.alignment = .leading
        stackview.translatesAutoresizingMaskIntoConstraints = false

        return stackview
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [verticalLabelStackView, verticalValuesStackView])
        stackview.axis = .horizontal
        stackview.spacing = 10
        stackview.distribution = .fill
        stackview.translatesAutoresizingMaskIntoConstraints = false

        return stackview
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    private func configure() {
        addSubview(horizontalStackView)
        horizontalStackView.pinToEdges(of: self, with: 8)
        
        backgroundColor = .prussianBlue
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
                
    }
    
    func setup(_ media: MediaViewModel?) {
        guard let media = media else { return }
        DispatchQueue.mainAsyncIfNeeded { [weak self] in
            guard let self = self else { return }
            ratingValue.text = "\(media.voteAverage) (\(media.voteCount))"
            genresValue.text = media.getGenresAsString()
            print("runtimes are:\(media.runtime), for id: \(media.id)")
            if let runtime = media.runtime.first {
                runtimeValue.text = "\(runtime) min"
            } else {
                runtimeValue.text = "N/A"
            }
            if let credits = media.credits {
                let directors = credits.crew.filter { $0.job == "Director" }
                if !directors.isEmpty {
                    directorValue.text = directors.compactMap { $0.name }.joined(separator: ", ")
                } else  {
                    let producers = credits.crew.filter { $0.job.contains("Producer") }
                    directorLabel.text = "Producer:"
                    directorValue.text = producers.compactMap { $0.name }.joined(separator: ", ")
                }
            } else {
                directorValue.text = ""
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class OverlayLogoView: UIView {
    let dateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "1979"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let pipeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "|"
        label.textAlignment = .left
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let averageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "9.2 (1.9M)"
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    let logoImageView: UIImageView = {
        let image = UIImage(named: "tmdbLogo_compact")!
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let aspectRatio = image.size.width / image.size.height
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 16),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio)
        ])
        return imageView
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        return stackView
    }()
    
    override init(frame: CGRect) {
    
        // Create the blur effect
        let blurEffect = UIBlurEffect(style: .regular)
        // Create the blur view using the blur effect
        blurView = UIVisualEffectView(effect: blurEffect)
        
        super.init(frame: frame)

        addBlur()
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(pipeLabel)
        stackView.addArrangedSubview(logoImageView)
        stackView.addArrangedSubview(averageLabel)
        addSubview(stackView)
        
        stackView.pinToEdges(of: self, with: 4)
        
        layer.cornerRadius = 4
        layer.masksToBounds = true
        
    }
    private var blurView: UIVisualEffectView
    
    func addBlur() {
        // Set up the transparent background color
        backgroundColor = UIColor.clear
        
        // Add the blur view as a subview and make it fill the entire OverlayLogoView
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        blurView.layer.cornerRadius = 4
        blurView.layer.masksToBounds = true
    }
    
    func setup(with media: MediaViewModel?) {
        guard let media = media else { return }
        let dateStr = media.dateAired.convertToYearFormat()
        
        dateLabel.text = dateStr
        averageLabel.text = "\(media.voteAverage) (\(media.voteCount))"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


