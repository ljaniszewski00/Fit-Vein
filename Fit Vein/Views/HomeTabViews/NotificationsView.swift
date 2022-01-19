//
//  NotificationsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        
                        LottieView(name: "notifications", loopMode: .loop)
                            .frame(width: screenWidth * 0.25, height: screenHeight * 0.15)
                    }
                    .padding()
                    .padding(.trailing, screenWidth * 0.05)
                    
                    HStack {
                        Spacer()
                        LottieView(name: "skeleton", loopMode: .loop)
                            .frame(width: screenWidth, height: screenHeight * 0.5)
                        Spacer()
                    }
                    Spacer()
                }
                .navigationTitle(String(localized: "NotificationsView_navigation_title"))
            }
            .navigationViewStyle(.stack)
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
