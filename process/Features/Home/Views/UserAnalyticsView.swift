//
//  UserAnalyticsView.swift
//  process
//
//  Created by maxfierro on 7/25/22.
//


import SwiftUI


/** */
struct AnalyticsScrollView: View {
    
    @ObservedObject var model: ProfileHomeViewModel
    
    /* MARK: Analytics view */
    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Text("User Analytics")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 24)
                
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<10) { _ in
                        GroupBox {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: 200, height: 200)
                        .padding(.leading, 16)
                    }
                }
            }
        }
    }
}
