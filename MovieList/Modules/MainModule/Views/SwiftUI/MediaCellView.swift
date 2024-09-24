//
//  MediaCellView.swift
//  MovieList
//
//  Created by macbook on 27/09/2023.
//

import SwiftUI
import MovieListFramework

struct MediaCellView: View {
    
    var media: MediaViewModel
    private let placeHolderImage: Image = Image(systemName: "popcorn")
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: fullPosterPath(posterPath: media.mainPosterURLString) ?? ""), content: { image in
                image
                    .resizable()
                    .frame(width: 80, height: 120)
                    .aspectRatio(contentMode: .fill)
                    .padding(.all, 0)
                    .foregroundColor(Color(uiColor: UIColor.prussianBlue))
                    .background(.white)
            }, placeholder: {
                placeHolderImage
                    .resizable()
                    .frame(width: 80, height: 120)
                    .aspectRatio(contentMode: .fill)
                    .padding(.all, 5)
                    .foregroundColor(Color(uiColor: UIColor.prussianBlue))
                    .background(.white)
            })
                .cornerRadius(8)
                .padding(.leading, 4)
                .padding([.top, .bottom], 4)
            VStack(alignment: .leading) {
                Text(media.title)
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.top, 5)
                Text(media.getStarRating())
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 2)
                Text(media.dateAired)
                    .foregroundStyle(.gray)
                    .font(.caption)
                Text(media.description)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.caption)
                    .lineLimit(3)
            }
            .padding([.leading, .bottom, .trailing], 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Make HStack fill available width
        .background(Color(uiColor: .systemFill))
        .cornerRadius(12)
        .padding(.leading, 0)
        .padding(.trailing, 0)
    }
    
    func fullPosterPath(posterPath: String?) -> String? {
        guard let posterPath = posterPath else {
            return nil
        }
        return "https://image.tmdb.org/t/p/w500/\(posterPath)"
    }
}

#Preview {
    var dummyData: [MediaItem] = {
        var myData: [MediaItem] = []
        for index in 0..<20 {
            myData.append(MocchyItems.expectedItems(at: index))
        }
        return myData
    }()
    List(dummyData, id: \.id) { mediaItem in
        MediaCellView(media: MediaViewModel.viewModelFrom(mediaItem: mediaItem))
    }
    .listStyle(.grouped)
    .preferredColorScheme(.dark)
}

private extension MediaViewModel {
    static func viewModelFrom(mediaItem: MediaItem) -> MediaViewModel {
        let uuid = UUID().uuidString
        return MediaViewModel(id: mediaItem.id,
                              uuid: uuid,
                              title: mediaItem.title,
                              description: mediaItem.overview,
                              mainPosterURLString: mediaItem.posterPath,
                              type: .movie,
                              dateAired: "12-10-2020",
                              language: "Eng",
                              rating: mediaItem.voteAverage,
                              popularity: mediaItem.popularity,
                              voteCount: mediaItem.voteCount,
                              voteAverage: mediaItem.voteAverage,
                              backdrops: [],
                              posters: [],
                              runtime: [],
                              languages: [],
                              genres: [])
    }
}
