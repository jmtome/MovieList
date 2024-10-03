//
//  MediaDetailView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 30/09/2024.
//

import SwiftUI
import MovieListFramework

class MediaDetailStore: ObservableObject {
    @Published var media: MediaViewModel = MediaViewModel()
    
    //Viper Actors
    var presenter: MediaDetailPresenterInputProtocol!
    init(presenter: MediaDetailPresenterInputProtocol) {
        self.presenter = presenter
    }
    var title: String { presenter.title ?? "No Title2" }
    func fetchMediaDetails() {
        presenter.viewDidLoad()
    }
}
extension MediaDetailStore: MediaDetailPresenterOutputProtocol {
    func updateUI() {
        //here i should also see to implement the behaviour when the user taps to fav/unfav in the detail screen
        DispatchQueue.main.async {
            self.media = self.presenter.getViewModel() ?? MediaViewModel()
            print("#### backdrops are")
            self.media.backdrops.forEach { backdrop in
//                print(backdrop.fullImagePath)
            }
            self.media.credits?.crew.forEach({ actor in
                print(actor.profilePicturePath)
            })
        }
    }
}

struct MediaDetailView: View {
    @StateObject var store: MediaDetailStore
    
    let media: MediaViewModel
    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .bottomLeading) {
                PostersCarouselView(media: store.media)
                    .frame(height: 230)
                OverlaySpecsView(media: store.media)
            }
            .padding(.horizontal, 0)
            
            ScrollView(.vertical, showsIndicators: false) {
                TitleAndOverviewView(media: store.media)
                    .padding(.horizontal, 4)
                
                MediaFacts(media: store.media)
                    .padding(.horizontal, 4)
                
                CastAndCrewView(media: store.media)
                    .padding(.horizontal, 4)
                Spacer()
            }
            .navigationTitle(store.title)
        }
        .onAppear {
            store.fetchMediaDetails()
        }
    }
}

#Preview {
    let media = MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: 3))
    let router = MediaDetailRouter()
    let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
    let presenter = MediaDetailPresenter(interactor: interactor, router: router, mediaTypeId: (.movie, media.id))
    let store = MediaDetailStore(presenter: presenter)
    NavigationStack {
        MediaDetailView(store: store, media: media)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostersCarouselView: View {
    let media: MediaViewModel
    let images: [Image] = [Image(.dummy5), Image(.dummy7), Image(.dummy3), Image(.dummy4), Image(.dummy1), Image(.dummy6), Image(.dummy2), Image(.dummy8), Image(.dummy9), Image(.dummy10), Image(.dummy11), Image(.dummy12) ]
    var body: some View {
        TabView {
            //            ForEach(0..<images.count, id: \.self) { index in
            //                images[index]
            //                    .resizable()
            //                    .scaledToFit()
            //                    .frame(width: UIScreen.main.bounds.width)
            //            }
            ForEach(0..<media.backdrops.count, id: \.self) { index in
                if let URL = URL(string: media.backdrops[index].fullImagePath) {
                    AsyncImage(url: URL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                } else {
                    Image(.image)
                }
                
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(.secondary)
        .clipped()
    }
}

struct OverlaySpecsView: View {
    let media: MediaViewModel
    var body: some View {
        HStack {
            Text(getMediaYear())
                .font(.headline)
            Text("|")
                .font(.headline)
            Image(.tmdbLogoCompact)
                .resizable()
                .scaledToFit()
                .frame(height: 16)
            Text("\(String(format: "%.1f", media.voteAverage)) (\(media.voteCount) votes)")
                .font(.headline)
        }
        .padding(4)
        .background(Material.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding([.leading, .bottom], 12)
    }
    private func getMediaYear() -> String {
        media.dateAired.convertToYearFormat()
    }
}

struct TitleAndOverviewView: View {
    let media: MediaViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(media.title.isEmpty ? "Title and Overview info" : media.title)
                .font(.headline)
                .padding([.top, .leading])
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
                .padding(.bottom, -10)
            
            Text(media.description)
                .font(.body)
                .padding()
                .foregroundStyle(Color(uiColor: .lightGray))
        }
        .frame(maxWidth: .infinity)
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct MediaFacts: View {
    let media: MediaViewModel
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Director:")
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
                Text("Runtime:")
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
                Text("Rating:")
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
                Text("Genre:")
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(getDirector())
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .lightGray))
                Text(getRuntime())
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .lightGray))
                Text(getRating())
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .lightGray))
                Text(getGenres())
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .lightGray))
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Make HStack fill available width
        .padding()
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    
    // These are probably ViewModel methods
    private func getDirector() -> String {
        if let credits = media.credits {
            let directors = credits.crew.filter { $0.job == "Director" }
            if !directors.isEmpty {
                return directors.compactMap(\.name).joined(separator: ", ")
            } else  {
                let producers = credits.crew.filter { $0.job.contains("Producer") }
                return producers.compactMap(\.name).joined(separator: ", ")
            }
        } else {
            return ""
        }
    }

    private func getRuntime() -> String {
        if let runtime = media.runtime.first {
            return "\(runtime) min"
        } else {
            return "N/A"
        }
    }
    private func getRating() -> String {
        "\(String(format: "%.1f", media.voteAverage)) (\(media.voteCount) votes)"
    }
    private func getGenres() -> String {
        media.getGenresAsString()
    }
}


// From carousel

//        ScrollView(.horizontal) {
//            HStack {
//                ForEach(0..<images.count, id: \.self) { index in
//                    images[index]
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: UIScreen.main.bounds.width)
//
//                }
//            }
        //        }