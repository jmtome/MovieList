//
//  Person.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation

struct Person: Codable {
    let adult: Bool
    let alsoKnownAs: [String]
    let biography: String
    let birthday: String?
    let deathday: String?
    let gender: Int
    let homepage: String?
    let id: Int
    let imdbID: String
    let knownForDepartment: String
    let name: String
    let placeOfBirth: String
    let popularity: Double
    let profilePath: String?
    let movieCredits: MovieCredits
    let images: ActorImages
    
    var profilePicturePath: String? {
        guard let profilePath = profilePath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w300/\(profilePath)"
    }
    
    enum CodingKeys: String, CodingKey {
        case adult
        case alsoKnownAs = "also_known_as"
        case biography
        case birthday
        case deathday
        case gender
        case homepage
        case id
        case imdbID = "imdb_id"
        case knownForDepartment = "known_for_department"
        case name
        case placeOfBirth = "place_of_birth"
        case popularity
        case profilePath = "profile_path"
        case movieCredits = "movie_credits"
        case images
    }
}

struct ActorImages: Codable {
    let profiles: [MediaImage]
}
