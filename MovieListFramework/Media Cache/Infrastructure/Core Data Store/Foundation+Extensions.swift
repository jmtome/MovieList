//
//  Foundation+Extensions.swift
//  MovieListFramework
//
//  Created by macbook on 19/09/2023.
//

import Foundation

//Extensions used internally by the Core Data Media Store

internal extension Array where Element: Encodable {
    func mapToJSONString() -> String? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

internal extension String? {
    func mapJSONToArray<T: Decodable>(of type: T.Type) -> [T] {
        guard let data = self?.data(using: .utf8),
              let array = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return array
    }
}
