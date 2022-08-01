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
    @Binding var sortSelection: Sort
    
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
                Button {
                    isEditingSearch = false
                    searchText = ""
                } label: {
                    Text("Cancel")
                }
            }
        }
        if isEditingSearch {
            HStack {
                Text("Sort by:")
                GroupBox {
                    Picker("Sort type", selection: $sortSelection) {
                        Text("Subtasks first").tag(Sort.topological)
                        Text("Due date").tag(Sort.dueDate)
                        Text("Creation date").tag(Sort.creationDate)
                        Text("Size").tag(Sort.size)
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.bottom, 4)
        }
    }
}


