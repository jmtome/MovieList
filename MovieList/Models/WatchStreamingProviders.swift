//
//  WatchStreamingProviders.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation

struct WatchProviderResponse: Codable {
    let id: Int
    let results: [String: CountryWatchProviders]
    
    func getProviders(for countryCode: String = Locale.current.region?.identifier ?? "US") -> CountryWatchProviders? {
        guard let currentCountry = UserDefaults.standard.string(forKey: "savedCountryCode") else {
            print("failed getting country code")
            return results[countryCode]
        }
        
        print("Region is, Current Country is \(currentCountry)")
        return results[currentCountry]
    }
}

extension WatchProviderResponse {
    // Helper function to load the JSON file
    static func loadMockData() -> WatchProviderResponse? {
        // Get the URL for the mock JSON file
        guard let url = Bundle.main.url(forResource: "streamJson", withExtension: "json") else {
            print("Failed to locate CastCrewMock.json in bundle.")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            
            // Decode the JSON data
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let watchStreamers = try decoder.decode(WatchProviderResponse.self, from: data)
            
            return watchStreamers
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

struct CountryWatchProviders: Codable, Equatable, Hashable {
    let link: String
    let flatrate: [Provider]?
    let rent: [Provider]?
    let buy: [Provider]?
}

struct Provider: Codable, Equatable, Hashable {
    let logoPath: String
    let providerID: Int
    let providerName: String
    let displayPriority: Int
    
    var providerLogoPath: String {
        return "https://image.tmdb.org/t/p/w300/\(logoPath)"
    }

    enum CodingKeys: String, CodingKey {
        case logoPath = "logo_path"
        case providerID = "provider_id"
        case providerName = "provider_name"
        case displayPriority = "display_priority"
    }
}
