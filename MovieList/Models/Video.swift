//
//  Video.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation

struct VideoResults: Codable, Equatable, Hashable {
    let results: [Video]
}
struct Video: Codable, Equatable, Hashable {
    let iso6391: String
    let iso31661: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let publishedAt: String
    let id: String
    
    var videoPath: String? {
        guard site == "YouTube" else {
            return nil
        }
        return "https://www.youtube.com/watch?v=\(key)"
    }
    
    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso_639_1"
        case iso31661 = "iso_3166_1"
        case name
        case key
        case site
        case size
        case type
        case official
        case publishedAt = "published_at"
        case id
    }
}
extension VideoResults {
    // Helper function to load the JSON file
    static func loadMockData() -> VideoResults? {
        // Get the URL for the mock JSON file
        guard let url = Bundle.main.url(forResource: "videoResultsJSON", withExtension: "json") else {
            print("Failed to locate videoResultsJSON.json in bundle.")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            
            // Decode the JSON data
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let movie = try decoder.decode(Movie.self, from: data)
            let videoResults = movie.videos
            
            return videoResults
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
            return nil
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
            
        } catch {
            print("error: ", error)
            return nil
            
        }
    }
}
