//
//  SmallProfilePicture.swift
//  process
//
//  Created by maxfierro on 7/29/22.
//

import SwiftUI

struct ProfilePictureView: View {
    
    @Binding var picture: UIImage
    
    var width: CGFloat
    var height: CGFloat
    var border: CGFloat
    var shadow: CGFloat
    
    var body: some View {
        Image(uiImage: picture)
            .resizable()
            .frame(width: width, height: height)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.gray, lineWidth: border)
            }
            .shadow(radius: shadow)
    }
}
