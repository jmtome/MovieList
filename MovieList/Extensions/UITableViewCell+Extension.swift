//
//  UITableViewCell+Extension.swift
//  MovieList
//
//  Created by macbook on 22/05/2023.
//

import UIKit

//MARK: - This Extension allows to access to the UIButton from the UIContextualAction in the cell,
// for it to work it must be set both in layoutSubviews() and in layoutIfNeeded()
extension UITableViewCell {
    var actionButton: UIButton? {
        superview?.subviews
            .filter({ String(describing: $0).range(of: "UISwipeActionPullView") != nil })
            .flatMap({ $0.subviews })
            .filter({ String(describing: $0).range(of: "UISwipeActionStandardButton") != nil })
            .compactMap { $0 as? UIButton }.first
    }
}
