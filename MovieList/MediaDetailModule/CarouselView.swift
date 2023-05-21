////
////  CarouselView.swift
////  MovieList
////
////  Created by macbook on 16/05/2023.
////
//
//import SwiftUI
//
//
//struct CarouselView: View {
//    @State private var currentIndex: Int = 0
//
//    @Binding var images: [UIImage]
//
//    var body: some View {
//        VStack {
//            Image(uiImage: images[currentIndex])
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 200)
//                .padding()
//
//            Spacer()
//
//            HStack {
//                ForEach(0..<images.count) { index in
//                    Circle()
//                        .foregroundColor(index == currentIndex ? .blue : .gray)
//                        .frame(width: 8, height: 8)
//                }
//            }
//            .padding(.bottom, 16)
//        }
//        .onAppear {
//            startCarousel()
//        }
//        .onDisappear {
//            stopCarousel()
//        }
//    }
//
//    private func startCarousel() {
//        let timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
//            currentIndex = (currentIndex + 1) % images.count
//        }
//        timer.fire()
//    }
//
//    private func stopCarousel() {
//        // Stop the carousel if needed
//    }
//}
//
