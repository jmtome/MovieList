//
//  UIViewController+Extension.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import UIKit
import SafariServices

extension UIViewController {
    func presentMLAlert(title: String, message: String, buttonTitle: String) {
        let alertVC = MLAlertView(title: title, message: message, buttonTitle: buttonTitle)
        alertVC.modalPresentationStyle  = .overFullScreen
        alertVC.modalTransitionStyle    = .crossDissolve
        showDetailViewController(alertVC, sender: self)
    }
    
    func presentDefaultError() {
        let alertVC = MLAlertView(title: "Something Went Wrong",
                                message: "We were unable to complete your task at this time. Please try again.",
                                buttonTitle: "Ok")
        alertVC.modalPresentationStyle  = .overFullScreen
        alertVC.modalTransitionStyle    = .crossDissolve
        showDetailViewController(alertVC, sender: self)
    }
    
    func presentSafariVC(with url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        showDetailViewController(safariVC, sender: self)
    }
}

extension UIViewController {
    func presentFavoriteAction(added: Bool) {
        let parentView: UIView = self.navigationController?.navigationBar ?? view
        
        displayFavoriteNotification(in: parentView, added)
    }
    
    
    fileprivate func displayFavoriteNotification(in view: UIView, _ added: Bool) {
        let animatedView = UIView(frame: CGRect(x: view.frame.width/2 - 100.5, y: -60, width: 200, height: 50))
        animatedView.backgroundColor = UIColor.label
        animatedView.layer.borderColor = UIColor.black.cgColor
        animatedView.layer.borderWidth = 0.5
        animatedView.layer.cornerRadius = 25
        
        view.addSubview(animatedView)
        
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.text = added ? "In Favorites" : "Unfavorited"
        label.textColor = .systemGray
        
        let image = UIImage(systemName: !added ? "star.fill" : "star")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .gold
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        animatedView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            stackView.centerXAnchor.constraint(equalTo: animatedView.centerXAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: animatedView.centerYAnchor)
        ])
        
        
        // Animate the appearance with ease-in-out animation
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
            animatedView.frame.origin.y = -7
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    imageView.image = UIImage(systemName: added ? "star.fill" : "star.slash")
                }, completion: nil)
            }
            
            
        }) { _ in
            // Animation completed, delay for 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Animate the disappearance with ease-in-out animation
                UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
                    animatedView.frame.origin.y = -self.view.frame.height
                }) { _ in
                    // Dismiss the entire view controller
                    animatedView.removeFromSuperview()
                }
            }
        }
    }
}
