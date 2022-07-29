//
//  SearchBar.swift
//  process
//
//  Created by maxfierro on 7/28/22.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var isEditingSearch: Bool
    
    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                    .padding(8)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                     
                            if isEditingSearch {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        isEditingSearch = true
                    }
            if isEditingSearch {
                Button(action: {
                    isEditingSearch = false
                    searchText = ""
                }) {
                    Text("Cancel")
                }
            }
        }
    }
}


