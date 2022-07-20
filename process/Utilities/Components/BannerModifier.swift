//
//  BannerModifier.swift
//  process
//
//  Created by maxfierro on 7/14/22.
//


import SwiftUI


/** View modifier displaying a banner suited for warnings, information, or
 general communications. Not all mine, adapted from:
 https://github.com/jboullianne/SwiftUIBanner */
struct BannerModifier: ViewModifier {
    
    struct BannerData {
        var title: String
        var detail: String
        var type: BannerType
    }
    
    @Binding var data: BannerData
    @Binding var show: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: BannerConstant.titleAndDetailsSpacing) {
                            Text(data.title)
                                .bold()
                            Text(data.detail)
                                .font(Font.system(size: BannerConstant.detailsFontSize))
                        }
                    }
                    .foregroundColor(BannerConstant.textColor)
                    .padding(12)
                    .background(data.type.tintColor)
                    .cornerRadius(BannerConstant.bannerCornerRadius)
                    Spacer()
                }
                .padding()
                .animation(BannerConstant.animation) // FIXME: Find non-deprecated replacement that works
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + BannerConstant.secondsBeforeDisappear) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }
}


extension View {
    func banner(data: Binding<BannerModifier.BannerData>, show: Binding<Bool>) -> some View {
        self.modifier(BannerModifier(data: data, show: show))
    }
}


struct Banner_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
    }
}
