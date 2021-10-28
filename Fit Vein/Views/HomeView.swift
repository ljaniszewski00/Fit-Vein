//
//  HomeView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    @Environment(\.colorScheme) var colorScheme
    
    init(homeViewModel: HomeViewModel, profileViewModel: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                
            }
        }
        .onAppear {
            self.homeViewModel.setup(sessionStore: sessionStore)
            self.profileViewModel.setup(sessionStore: sessionStore)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore()
                
                HomeView(homeViewModel: homeViewModel, profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
