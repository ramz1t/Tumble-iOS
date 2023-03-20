//
//  SearchBodyView.swift
//  tumble-ios
//
//  Created by Adis Veletanlic on 11/20/22.
//

import SwiftUI

struct SearchResults: View {
    
    let searchText: String
    let numberOfSearchResults: Int
    let searchResults: [Response.Programme]
    let onOpenProgramme: (String) -> Void
    
    @Binding var universityImage: Image?
    
    var body: some View {
        VStack {
            HStack {
                Text("\(numberOfSearchResults) results for \"\(searchText)\"")
                    .searchResultsField()
                Spacer()
            }
            ScrollView {
                LazyVStack {
                    ForEach(searchResults, id: \.id) { programme in
                        ProgrammeCard(
                            programme: programme,
                            universityImage: universityImage,
                            onOpenProgramme: onOpenProgramme
                        )
                    }
                }
            }
            .background(Color.background)
        }
    }
}
