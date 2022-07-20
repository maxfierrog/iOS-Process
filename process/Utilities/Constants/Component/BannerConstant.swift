//
//  BannerConstant.swift
//  process
//
//  Created by maxfierro on 7/20/22.
//

import Foundation
import SwiftUI


/** Types of banners available by background color. */
enum BannerType {
    
    case Info
    case Warning
    case Success
    case Error
    
    var tintColor: Color {
            switch self {
            case .Info:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .Success:
                return Color.green
            case .Warning:
                return Color.yellow
            case .Error:
                return Color(red: 180/255, green: 80/255, blue: 80/255)
        }
    }
}


/** Centralized static class for banner customization constants. */
class BannerConstant {
    
    /* MARK: Customization */
    
    public static let animation: Animation = .easeInOut
    public static let textColor: Color = .white
    public static let secondsBeforeDisappear: CGFloat = 5
    public static let titleAndDetailsSpacing: CGFloat = 5
    public static let detailsFontSize: CGFloat = 12
    public static let bannerCornerRadius: CGFloat = 8
    
}
