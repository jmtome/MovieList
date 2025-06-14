//
//  MediaCellView.swift
//  MovieList
//
//  Created by macbook on 27/09/2023.
//

import SwiftUI
import MovieListFramework

struct MediaCellGridView: View {
    var media: MediaViewModel
    var isFavorite: Bool
    private let placeHolderImage: Image = Image(systemName: "popcorn")
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            CachedAsyncImage(url: URL(string: media.mainPosterURLString ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } placeholder: {
                placeHolderImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .tint(.white)
            }
            if isFavorite {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.purple)
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 10, weight: .bold))
                        .padding(0)
                }
                .frame(width: 20, height: 20)
                .padding(0)
            }

        }
        .onAppear {
            print("### MediaCellView.onAppear is fav: \(media.isFavorite)")
        }
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
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    ScrollView {
        LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
            ForEach(dummyData, id: \.id) { mediaItem in
                MediaCellGridView(media: MediaViewModel.viewModelFrom(mediaItem: mediaItem), isFavorite:  Bool.random())
            }
        }
    }
    .listStyle(.grouped)
    .preferredColorScheme(.dark)
}

struct MediaCellListView: View {
    
    var media: MediaViewModel
    private let placeHolderImage: Image = Image(.placeholder300W)
    
    var body: some View {
        HStack(alignment: .top) {
            CachedAsyncImage(url: URL(string: media.mainPosterURLString ?? ""), content: { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .padding(.all, 0)
                    .foregroundColor(Color(uiColor: UIColor.prussianBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }, placeholder: {
                placeHolderImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .tint(.white)
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
    }
}

