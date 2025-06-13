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
    
    var onDismissClosure: (() -> Void)? = nil
    var onSeenClosure: ((MediaViewModel) -> Void)? = nil
    //Viper Actors
    var presenter: MediaDetailPresenterInputProtocol!
    init(presenter: MediaDetailPresenterInputProtocol, onDismissClosure: (() -> Void)?) {
        self.presenter = presenter
        self.onDismissClosure = onDismissClosure
    }
    var title: String { presenter.title ?? "Loading..." }
    func fetchMediaDetails() {
        presenter.viewDidLoad()
    }
    func handleFavoriteAction() {
        presenter.handleFavoriteAction()
    }
    
    func isInFavorites() -> Bool {
        presenter.isMovieInFavorites()
    }
    
    func onDismiss() {
        onDismissClosure?()
    }
    func onSeenMedia() {
        onSeenClosure?(media)
    }
    
    func buildStoreForActor(for actorId: Int) -> ActorProfileStore {
        let interactor = ActorProfileInteractor(networkingService: TMDBNetworkingService())
        let presenter = ActorProfilePresenter(interactor: interactor)
        let store = ActorProfileStore(presenter: presenter, actorId: actorId)
        presenter.output = store
        interactor.output = presenter
        return store
    }
}
extension MediaDetailStore: MediaDetailPresenterOutputProtocol {
    func updateUI() {
        DispatchQueue.main.async {
            self.media = self.presenter.getViewModel() ?? MediaViewModel()
            self.onSeenMedia()
        }
    }
}

struct MediaDetailView: View {
    @StateObject var store: MediaDetailStore
    
    @State private var wasCoveredByTopView = false // Tracks if a view was hidden by another view
    let media: MediaViewModel
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .bottomLeading) {
                    PostersCarouselView(media: store.media)
                        .frame(height: 180)
                    OverlaySpecsView(media: store.media)
                }
                .padding(.horizontal, 0)
                
                TitleAndOverviewView(media: store.media)
                    .padding(.horizontal, 4)
                
                MediaFacts(media: store.media)
                    .padding(.horizontal, 4)
                
                MediaStreamersView(streamers: store.media.countryWatchProviders)
                    .padding(.horizontal, 4)
                
                CastAndCrewView(media: store.media, buildActorStoreClosure: store.buildStoreForActor)
                    .padding(.horizontal, 4)
                CrewListView(media: store.media, buildActorStoreClosure: store.buildStoreForActor)
                
                VideosView(videos: store.media.videos)
                    .padding(.horizontal, 4)
            }
            .navigationTitle(store.title)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        store.handleFavoriteAction()
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                    }) {
                        Image(systemName: store.isInFavorites() ? "star.fill" : "star")
                    }
                }
            }
        }
        .onAppear {
            if !wasCoveredByTopView { store.fetchMediaDetails() }
            else { print("$$$$ appeared from an upper dismissal")}
        }
        .onDisappear {
            store.onDismiss()
            wasCoveredByTopView = true
            print("$$$$ dissapearing")
        }
    }
}

#Preview {
    let media = MediaViewModel.viewModelFrom(mediaItem: MocchyItems.expectedItems(at: 3))
    let router = MediaDetailRouter()
    let interactor = MediaDetailInteractor(networkingService: TMDBNetworkingService())
    let presenter = MediaDetailPresenter(interactor: interactor, router: router, mediaTypeId: (.movie, media.id))
    let store = MediaDetailStore(presenter: presenter, onDismissClosure: nil)
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
            ForEach(0..<media.backdrops.count, id: \.self) { index in
                if let URL = URL(string: media.backdrops[index].fullImagePath) {
                    CachedAsyncImage(url: URL) { image in
                        image
                            .resizable()
                            .scaledToFill()
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
        .background(.clear)
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

