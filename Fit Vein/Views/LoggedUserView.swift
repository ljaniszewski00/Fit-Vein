//
//  LoggedUserView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject private var profileViewModel = ProfileViewModel()
    
    @State private var progress: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
//            if !profileViewModel.fetchingData {
                TabView {
                    HomeView()
                        .environmentObject(sessionStore)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                        .tag(0)
                    
                    WorkoutView()
                        .environmentObject(sessionStore)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                        .tabItem {
                            Image(systemName: "figure.walk")
                        }
                        .tag(1)
                    
                    ProfileView(profileViewModel: profileViewModel)
                        .environmentObject(sessionStore)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                        .tabItem {
                            Image(systemName: "person.fill")
                        }
                        .tag(2)
                }
//            } else {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        ProgressView("Loading user's data")
//                            .progressViewStyle(RingProgressViewStyle())
//                        Spacer()
//                    }
//                    Spacer()
//                }
//            }
        }
        .onAppear {
            self.profileViewModel.setup(sessionStore: sessionStore)
        }
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore()
                
                LoggedUserView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
