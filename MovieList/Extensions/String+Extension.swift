//
//  String+Extension.swift
//  MovieList
//
//  Created by macbook on 25/05/2023.
//

import Foundation

extension String {
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        
        return dateFormatter.date(from: self)
    }
    
    func convertToYearFormat() -> String {
        guard let date = self.convertToDate() else { return "N/A" }
        
        return date.formatted(.dateTime.year())
    }
}
