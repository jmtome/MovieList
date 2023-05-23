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
