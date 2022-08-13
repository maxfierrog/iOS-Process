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
    @Binding var sortSelection: TaskSort
    
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
                        withAnimation {
                            isEditingSearch = true
                        }
                    }
            if isEditingSearch {
                Button {
                    withAnimation {
                        isEditingSearch = false
                        searchText = ""
                    }
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
                        Text("None").tag(TaskSort.none)
                        Text("Subtasks first").tag(TaskSort.topological)
                        Text("Due the soonest").tag(TaskSort.soonestDue)
                        Text("Recently created").tag(TaskSort.recentlyCreated)
                        Text("Largest").tag(TaskSort.largest)
                        Text("Smallest").tag(TaskSort.smallest)
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.bottom, 4)
        }
    }
}


