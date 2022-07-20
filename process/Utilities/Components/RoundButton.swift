//
//  RoundButton.swift
//  process
//
//  Created by Maximo Fierro on 7/20/22.
//


import SwiftUI


/** A round floating action button component. Not original -- made by
 Gordan Glavas, and modified by me. */
struct RoundButton<ImageView: View>: ViewModifier {

    let color: Color
    let image: ImageView
    let action: () -> Void

    private let size: CGFloat = 60
    private let margin: CGFloat = 17

    func body(content: Content) -> some View {
        GeometryReader { geo in
            ZStack {
                Color.clear
                content
                button(geo)
            }
        }
    }

    @ViewBuilder private func button(_ geo: GeometryProxy) -> some View {
        image
            .imageScale(.large)
            .frame(width: size, height: size)
            .background(Circle().fill(color))
            .onTapGesture(perform: action)
            .offset(x: (geo.size.width - size) / 2 - (margin + 8),
                    y: (geo.size.height - size) / 2 - margin)
    }
}


extension View {
    func roundButton<ImageView: View>(
        color: Color,
        image: ImageView,
        action: @escaping () -> Void) -> some View {
        self.modifier(RoundButton(color: color,
                                image: image,
                                action: action))
        }
}
