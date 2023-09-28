//
//  MediaCellView.swift
//  MovieList
//
//  Created by macbook on 27/09/2023.
//

import SwiftUI

struct MediaCellView: View {
    
    var title: String = "Matrix Revolutions"
    var posterImage: Image = Image(systemName: "popcorn")
    var dateLabel: String = "2019-05-22"
    var description: String = "An exploratory dive into the deepest depths of the ocean of a daring research team spirals into chaos when a malevolent mining operation threatens their mission and forces them into a high-stakes battle for survival."
    var starRating: String = "★★★★☆"
    
    var body: some View {
        HStack(alignment: .center) {
            posterImage
                .resizable()
                .frame(height: 120)
                .aspectRatio(0.12, contentMode: .fit)
                .padding(.all, 5)
                .foregroundColor(Color(uiColor: UIColor.prussianBlue))
                .background(.white)
                .cornerRadius(20)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .padding(.top, 5)
                    .padding(.bottom, 0)
                Text(starRating)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .padding(.bottom, 2)
                Text(dateLabel)
                    .font(.subheadline)
                Text(description)
                    .foregroundStyle(Color(uiColor: .label))
                    .font(.caption)
                    .lineLimit(3)
            }
            .padding(.leading, 2)
            .padding(.bottom, 10)
            .padding(.trailing, 10)
        }
        .background(Color(uiColor: .systemFill))
        .cornerRadius(10)
        .padding(.leading, 8)
        .padding(.trailing, 8)
    }
}

#Preview {
    MediaCellView()
        .preferredColorScheme(.dark)
}
