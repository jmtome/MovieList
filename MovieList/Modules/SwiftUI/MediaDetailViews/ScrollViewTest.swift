//
//  ScrollViewTest.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 05/10/2024.
//

import SwiftUI

struct ScrollPositionModifier: View {
    @State private var scrollViewPosition: Int? = 0
    var body: some View {
        VStack {
            Text("\(scrollViewPosition)")
            ScrollView {
                ForEach(0..<100, id: \.self) { num in
                    Rectangle()
                        .fill(Color.green.opacity(0.5))
                        .frame(height: 100)
                        .cornerRadius(10)
                        .padding()
                        .overlay {
                            Text(verbatim: num.formatted())
                                .font(.system(size: 18,weight: .bold))
                        }
                }.scrollTargetLayout()
            }.scrollPosition(id: $scrollViewPosition)
            if scrollViewPosition ?? 0 > 30 {
                Text("Test")
            }
            
        }
    }
}



#Preview {
    ScrollPositionModifier()
}
