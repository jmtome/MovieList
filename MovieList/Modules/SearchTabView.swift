import SwiftUI
import MovieListFramework

struct SearchTabView: View {
    @ObservedObject var viewModel: MediaViewStore
    @Binding var searchScope: Int
    let homeMode: HomeMode
    @State private var searchText: String = ""
    var searchResults: [MediaViewModel] {
        if !searchText.isEmpty {
            viewModel.mediaVM
        } else {
            []
        }
    }

    @State private var viewIsPresented: Bool = false
    var body: some View {
        VStack {
            // Custom Search Bar
            CustomSearchBar(searchText: $searchText, onSearch: {
                performSearch()
            }, onCancel: {
                searchText = ""
            })
            .padding(.top, 8)
            Picker("Select Scope", selection: $searchScope) {
                Text("Movies").tag(0)
                Text("Series").tag(1)
            }
            .padding(.top, 2)
            .pickerStyle(.segmented)
            .onChange(of: searchScope) {
                guard viewIsPresented else {
                    print("#### scope changed but im not actively in search tab")
                    return
                }
                performSearch()
            }
            
            // Display search results (example)
            if searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Recently Visited")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                            Button {
                                viewModel.clearRecentlyViewedMedia()
                            } label: {
                                Image(systemName: "xmark")
                                    .tint(.gray)
                            }
                            .padding(.trailing)
                        }
                        
                        if viewModel.recentlyViewedMedia.isEmpty {
                            VStack {
                                Text("No Recently Viewed Media")
                                    .foregroundStyle(.gray)
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                        } else {
                            MainScreenGridRow(newVM: viewModel, filteredData: Array(viewModel.recentlyViewedMedia), mediaCategory: .recentlyViewed)
                                .padding(.horizontal)
                        }
                        HStack {
                            Text("Last Search")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                            Spacer()
                            Button {
                                viewModel.clearLastSearchMedia()
                            } label: {
                                Image(systemName: "xmark")
                                    .tint(.gray)
                            }
                            .padding(.trailing)
                        }
                        if viewModel.lastSearch.isEmpty {
                            VStack {
                                Text("No Last Searched Media")
                                    .foregroundStyle(.gray)
                            }
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                        } else {
                            MainScreenGridRow(newVM: viewModel, filteredData: Array(viewModel.recentlyViewedMedia), mediaCategory: .lastSearch)
                                .padding(.horizontal)
                        }
                    }
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .padding(.top, 16)
                    Spacer() // Push content to the top
                }
            } else {
                if homeMode == .list {
                    MainScreenList(newVM: viewModel, filteredData: searchResults)
                    //                        .transition(.blurReplace) // Add a sliding transition
                } else {
                    MainScreenVerticalGrid(newVM: viewModel, filteredData: searchResults)
                }
            }
        }
        
        .onChange(of: searchText) {
            performSearch() // Trigger live search on text change
        }
        .onAppear {
            viewIsPresented = true
            print("#### this being called")
            performSearch() // Initial load
        }
        .onDisappear {
            viewIsPresented = false
            print("#### dissapeared from searchtab")
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func performSearch() {
        print("#### scope changed inside search")
        guard !searchText.isEmpty else {
            //            searchResults = []
            return
        }
        guard let scope = SearchScope(rawValue: searchScope) else { return }
        print("#### [Search] scope is: \(scope), search query is: \(searchText)")
        viewModel.updateSearchResults(with: searchText, scope: scope)
    }
}