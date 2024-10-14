import SwiftUI
import MovieListFramework

struct MainScreenGrid: View {
    @ObservedObject var newVM: MediaViewStore
    let filteredData: [MediaViewModel]
    @State var isPressed: Bool = false
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    let rows = [
        //        GridItem(.adaptive(minimum: 80))
        GridItem(.fixed(120))
    ]
    var body: some View {
        if newVM.isFetchingAll {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(3)
        } else {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .trending)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .popular)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .nowPlaying)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .upcoming)
                    MainScreenGridRow(newVM: newVM, filteredData: filteredData, mediaCategory: .topRated)
                }
                .padding(.top)
                .padding(.leading)
            }
        }
    }
}