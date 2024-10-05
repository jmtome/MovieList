//
//  SortingOption.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation
import UIKit

enum SortingOption: SortableEnum {
    var id: SortingOption { self }
    
    case relevance
    case date
    case rating
    case title
    
    var title: String {
        switch self {
        case .relevance: return "Popularity"
        case .date: return "Date"
        case .rating: return "Rating"
        case .title: return "Name"
        }
    }
    
    var identifier: String {
        return "\(self)"
    }

    var image: UIImage {
        switch self {
        case .relevance: return UIImage(systemName: "chevron.up")!
        case .date: return UIImage(systemName: "chevron.up")!
        case .rating: return UIImage(systemName: "chevron.up")!
        case .title: return UIImage(systemName: "chevron.up")!
        }
    }
    
    var swiftUIImageString: String {
        switch self {
        case .relevance: return "chevron.up"
        case .date: return "chevron.up"
        case .rating: return "chevron.up"
        case .title: return "chevron.up"
        }
    }
}
