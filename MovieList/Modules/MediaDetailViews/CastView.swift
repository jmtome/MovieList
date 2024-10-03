//
//  CastView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 01/10/2024.
//

import SwiftUI
import MovieListFramework


struct CastAndCrewView: View {
    let media: MediaViewModel
    var body: some View {
        VStack {
            Text("Cast")
                .font(.headline)
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(getCrew(), id: \.id) { cast in
                        CastView(cast: cast)
//                            .background(.yellow)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func getCrew() -> [Cast] {
        return media.credits?.cast ?? []
    }
}

#Preview {
    let mock = MediaCredits.loadMockData()!
    let media = MediaViewModel(mock)
    CastAndCrewView(media: media)
}

struct CastView: View {
    let cast: Cast
    var body: some View {
        VStack(alignment: .center) {
            if let profilePath = cast.profilePicturePath, let URL = URL(string: profilePath) {
                AsyncImage(url: URL) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Image(.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                        ProgressView()
                            .tint(.black)
                    }
                }
//                .padding(4)
                .scaledToFit()
                .frame(width: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 0)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cast.name)
                        .font(.body.bold())
                    Text(cast.character)
                        .font(.caption2)
                }
            }
        }
        .frame(width: 100)
        .onAppear {
            let personMock = Person.loadMockData()
            print("person mock")
            print(personMock)
        }
    }
}




private extension MediaCredits {
    // Helper function to load the JSON file
    static func loadMockData() -> MediaCredits? {
        // Get the URL for the mock JSON file
        guard let url = Bundle.main.url(forResource: "CastCrewMock", withExtension: "json") else {
            print("Failed to locate CastCrewMock.json in bundle.")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            
            // Decode the JSON data
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let mediaCredits = try decoder.decode(MediaCredits.self, from: data)
            
            return mediaCredits
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
