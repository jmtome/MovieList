//
//  SortMenuView.swift
//  MovieList
//
//  Created by Juan Manuel Tome on 27/09/2024.
//

import SwiftUI

protocol SortableEnum: CaseIterable, Identifiable, Hashable {
    var title: String { get }
}

struct SortMenuView<T: SortableEnum>: View where T.AllCases: RandomAccessCollection {
    @Binding var sortOption: T
    @Binding var isAscending: Bool
    
    var body: some View {
        Menu {
            ForEach(T.allCases) { category in
                let isSelected = sortOption == category
                
                Toggle(isOn: Binding(
                    get: { isSelected },
                    set: { newValue in
                        if isSelected {
                            isAscending.toggle()
                        } else {
                            sortOption = category
                            isAscending = true
                        }
                    }
                )) {
                    Label {
                        Text(category.title)
                    } icon: {
                        if isSelected && category.title != "All" {
                            Image(systemName: isAscending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
        } label: {
            Label("", systemImage: "ellipsis.circle")
        }
    }
}


struct SortMenuView_Previews: PreviewProvider {
    @State static var sortOption: SortingOption = .relevance
    @State static var isAscending: Bool = true
    
    static var previews: some View {
        SortMenuView(sortOption: $sortOption, isAscending: $isAscending)
    }
}

