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
    let buildActorStoreClosure: ((Int) -> ActorProfileStore)!
    var body: some View {
        VStack {
            Text("Cast")
                .font(.headline)
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(getCrew(), id: \.id) { cast in
                        NavigationLink {
                            ActorProfileView(store: buildActorStoreClosure(cast.id))
                        } label: {
                            CastView(cast: cast)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
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

struct CrewListView: View {
    let media: MediaViewModel
    let buildActorStoreClosure: ((Int) -> ActorProfileStore)!
    var body: some View {
        VStack {
            Text("Crew")
                .font(.headline)
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(getCrew(), id: \.id) { cast in
                        NavigationLink {
                            ActorProfileView(store: buildActorStoreClosure(cast.id))
                        } label: {
                            CrewView(cast: cast)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    
    private func getCrew() -> [Crew] {
        return media.credits?.crew ?? []
    }
}

#Preview {
    let mock = MediaCredits.loadMockData()!
    let media = MediaViewModel(mock)
    VStack {
        NavigationStack {
            CastAndCrewView(media: media, buildActorStoreClosure: { id in
                let interactor = ActorProfileInteractor(networkingService: TMDBNetworkingService())
                let presenter = ActorProfilePresenter(interactor: interactor)
                let store = ActorProfileStore(presenter: presenter, actorId: id)
                presenter.output = store
                return store
            })
        }
        NavigationStack {
            CrewListView(media: media, buildActorStoreClosure: { id in
                let interactor = ActorProfileInteractor(networkingService: TMDBNetworkingService())
                let presenter = ActorProfilePresenter(interactor: interactor)
                let store = ActorProfileStore(presenter: presenter, actorId: id)
                presenter.output = store
                return store
            })
        }
    }
}

struct CastView: View {
    let cast: Cast
    var body: some View {
        VStack(alignment: .center) {
                CachedAsyncImage(url: URL(string: cast.profilePicturePath  ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Image(.placeholder300W)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 95)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        ProgressView()
                            .tint(.black)
                    }
                }
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
        .frame(width: 100)
    }
}

struct CrewView: View {
    let cast: Crew
    var body: some View {
        VStack(alignment: .center) {
            CachedAsyncImage(url: URL(string: cast.profilePicturePath ?? "")) { image in
                image.resizable()
            } placeholder: {
                ZStack {
                    Image(.placeholder300W)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 95)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    ProgressView()
                        .tint(.black)
                }
            }
            .scaledToFit()
            .frame(width: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.bottom, 0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cast.name)
                    .font(.body.bold())
                Text(cast.job)
                    .font(.caption2)
            }
        }
        .frame(width: 100)
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
