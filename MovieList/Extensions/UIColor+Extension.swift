//
//  UIColor+Extension.swift
//  MovieList
//
//  Created by macbook on 29/05/2023.
//

import UIKit
import SwiftUI

public extension UIColor {
    static let softDark = UIColor(red: 11/255, green: 16/255, blue: 21/255, alpha: 1)
    static let softBlue = UIColor(red: 59/255, green: 67/255, blue: 103/255, alpha: 1)
    static let prussianBlue = UIColor(red: 29/255, green: 50/255, blue: 73/255, alpha: 1)
    static let softBlue2 = UIColor(red: 15/255, green: 22/255, blue: 29/255, alpha: 1)
    static let gold = #colorLiteral(red: 0.9882352941, green: 0.7607843137, blue: 0, alpha: 1)
}

public extension Color {
    static let softDark = Color(uiColor: .softDark)
    static let softBlue = Color(uiColor: .softBlue)
    static let prussianBlue = Color(uiColor: .prussianBlue)
    static let softBlue2 = Color(uiColor: .softBlue2)
    static let gold = Color(uiColor: .gold)
}
