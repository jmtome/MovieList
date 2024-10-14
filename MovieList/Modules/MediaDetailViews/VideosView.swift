//
//  VideosView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import Foundation
import SwiftUI
import YouTubePlayerKit

struct VideosView: View {
    let videos: [Video]
    @State private var videosToShow = 3 // Number of videos to show initially
    @State private var isExpanded = false // Toggle for collapsing

    
    private var filteredVideos: [Video] {
        videos.filter { $0.type == "Trailer" /*|| $0.type == "Teaser"*/ }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trailers")
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center) {
                    // Determine the number of videos to show based on videosToShow
                    let displayedVideos = Array(filteredVideos.prefix(videosToShow))

                    ForEach(displayedVideos.indices, id: \.self) { index in
                        if let videoUrl = displayedVideos[index].videoPath {
                            YouTubePlayerView(YouTubePlayer(stringLiteral: videoUrl)) { state in
                                switch state {
                                case .idle:
                                    ProgressView()
                                case .ready:
                                    EmptyView()
                                case .error(_):
                                    Text(verbatim: "YouTube player couldn't be loaded")
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .aspectRatio(16/9, contentMode: .fit)
                            .padding(.vertical)
                        }
                    }

                    // Button to show more videos or collapse
                    Button(action: {
                        withAnimation {
                            if isExpanded {
                                // Collapse the list
                                videosToShow = 3
                                isExpanded = false
                            } else {
                                // Show 3 more videos if available, or collapse if all are shown
                                let nextCount = videosToShow + 3
                                if nextCount >= videos.count {
                                    videosToShow = videos.count
                                    isExpanded = true
                                } else {
                                    videosToShow = nextCount
                                }
                            }
                        }
                    }) {
                        if filteredVideos.count > videosToShow {
                            Text(isExpanded ? "Collapse \(Image(systemName: "chevron.up"))" : "Show more \(Image(systemName: "chevron.down"))")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.vertical)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    let videoResults = VideoResults.loadMockData()!.results
    VideosView(videos: videoResults)
}
