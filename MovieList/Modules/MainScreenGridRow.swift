import SwiftUI
import MovieListFramework

struct MainScreenGridRow: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    let mediaCategory: MediaCategory
    @State var isPressed: Bool = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    let rows = [
        GridItem(.fixed(120))
    ]
    
    private var mediaData: [MediaViewModel] {
        switch mediaCategory {
        case .popular:
            return newVM.popularMedia
        case .topRated:
            return newVM.topRatedMedia
        case .upcoming:
            return newVM.upcomingMedia
        case .search:
            return filteredData
        case .nowPlaying:
            return newVM.nowPlayingMedia
        case .trending:
            return newVM.trendingMedia
        case .recentlyViewed:
            return newVM.recentlyViewedMedia
        case .lastSearch:
            return newVM.lastSearch
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if mediaCategory != .lastSearch && mediaCategory != .recentlyViewed && mediaCategory != .search {
                HStack {
                    Text(mediaCategory.title())
                    Spacer()
                    
                    NavigationLink(
                        destination:
                            VStack {
                                MainScreenVerticalGrid(newVM: newVM, filteredData: mediaData)
                            }
                            .navigationTitle(mediaCategory.title())
                    ) {
                        Image(systemName: "chevron.right")
                            .padding(.trailing)
                            .tint(.white)
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, alignment: .center, spacing: 20) {
                    ForEach(mediaData, id: \.id) { mediaItem in
                        NavigationLink(destination: MediaDetailView(store: newVM.buildStoreForDetails(with: mediaItem), media: mediaItem)) {
                            MediaCellGridView(media: mediaItem)
                                .onAppear {
                                    impactFeedback.prepare()
                                }
                                .scaleEffect(isPressed ? 5 : 1.0) // Adjust the scale value for a more dramatic effect
                                .animation(.spring(response: 0.4, dampingFraction: 0.5), value: isPressed) // Control the speed and bounce of the animation
                                .gesture(
                                    LongPressGesture(minimumDuration: 1.5) // Adjust the duration if needed
                                        .onChanged { _ in
                                            withAnimation {
                                                isPressed = true
                                            }
                                            impactFeedback.impactOccurred()
                                        }
                                        .onEnded { _ in
                                            withAnimation {
                                                isPressed = false
                                            }
                                        }
                                )
                                .contextMenu {
                                    Button(action: {
                                        // Handle Favorite action
                                        newVM.handleFavorite(mediaItem)
                                    }) {
                                        let isFavorite = newVM.isFavorite(mediaItem)
                                        Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: isFavorite ? "star.fill" : "star")
                                    }
                                    Button(action: {
                                        // Handle Bookmark action
                                    }) {
                                        Label("Bookmark", systemImage: "bookmark")
                                    }
                                }
                        }
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}