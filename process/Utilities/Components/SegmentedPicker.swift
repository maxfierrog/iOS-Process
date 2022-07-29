//
//  SegmentedPicker.swift
//  process
//
//  Created by maxfierro on 7/28/22.
//

import SwiftUI

struct SegmentedPicker: View {
    
    var accessibilityText: String
    var categories: [String]
    
    @Binding var selectedCategory: Int
    
    var body: some View {
        Picker(accessibilityText, selection: $selectedCategory) {
            ForEach(categories.indices, id: \.self) { index in
                Text(categories[index]).tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
}
