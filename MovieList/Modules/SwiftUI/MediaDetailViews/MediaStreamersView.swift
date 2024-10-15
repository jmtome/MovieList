//
//  MediaStreamersView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 04/10/2024.
//

import SwiftUI

struct MediaStreamersView: View {
    let streamers: CountryWatchProviders?
    var body: some View {
        VStack(alignment: .leading) {
            Text("Where to watch")
                .foregroundStyle(Color(uiColor: .white.withAlphaComponent(0.95)))
            
            if let streamers = streamers, let streamingProviders = streamers.flatrate {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(streamingProviders.indices, id:\.self) { index in
                            StreamingProviderView(provider: streamingProviders[index])
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    if let URL = URL(string: streamers.link) {
                                        UIApplication.shared.open(URL)
                                    }
                                }
                        }
                    }
                }
            } else {
                HStack {
                    Text("No Streaming providers for this country")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            
            HStack {
                Spacer()
                Text("Powered By:\n JustWatch")
                    .font(.caption2)
                Image(.justWatch)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
            }
            .onTapGesture {
                if let url = URL(string: "https://www.justwatch.com") {
                    UIApplication.shared.open(url)
                }
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.prussianBlue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct StreamingProviderView: View {
    let provider: Provider
    var body: some View {
        if let URL = URL(string: provider.providerLogoPath) {
            VStack(alignment: .center) {
                CachedAsyncImage(url: URL) { image in
                    image.resizable()
                } placeholder: {
                    ZStack {
                        Image(.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40)
                        ProgressView()
                            .tint(.black)
                    }
                }
                .scaledToFit()
                .frame(width: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 0)
                
                Text(provider.providerName)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .onAppear {
                print("logo path: \(provider.logoPath)")
            }
        }
    }
}

#Preview {
    VStack {
        let streamers = WatchProviderResponse.loadMockData()!
        MediaStreamersView(streamers: streamers.getProviders()!)
        
        MediaStreamersView(streamers: nil)
    }
}
