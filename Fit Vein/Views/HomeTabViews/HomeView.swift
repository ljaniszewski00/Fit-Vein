//
//  HomeView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                Group {
                    if !networkManager.isConnected {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                LottieView(name: "noInternetConnection", loopMode: .loop)
                                    .frame(width: screenWidth * 0.7, height: screenHeight * 0.7)
                                Spacer()
                            }
                            Spacer()
                        }
                    } else {
                        if profileViewModel.profile != nil {
                            withAnimation {
                                ScrollView(.vertical) {
                                    HomeTabSubViewShareView().environmentObject(homeViewModel).environmentObject(profileViewModel)
                                        .frame(height: screenHeight * 0.25)
                                        .padding(.bottom, screenHeight * 0.055)
                                        .offset(y: -screenHeight * 0.02)

                                    Group {
                                        if let posts = homeViewModel.posts {
                                            if posts.count != 0 {
                                                ForEach(posts) { post in
                                                    HomeTabSubViewPostsView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
                                                        .frame(height: screenHeight * calculatePostFrameHeightMultiplier(post: post))
                                                        .background(Color(uiColor: .systemGray6))
                                                }
                                            } else {
                                                VStack {
                                                    Text(String(localized: "HomeView_nothing_to_present"))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.accentColor)
                                                        .padding(.top, screenHeight * 0.07)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        } else {
                                            if let followedIDs = self.profileViewModel.profile!.followedIDs {
                                                if followedIDs.count != 0 {
            //                                            HomeTabPostsFetchingView()
            //                                                .frame(width: screenWidth, height: screenHeight)
                                                    VStack {
                                                        Text(String(localized: "HomeView_nothing_to_present"))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.accentColor)
                                                            .padding(.top, screenHeight * 0.07)
                                                        
                                                        Spacer()
                                                    }
                                                } else {
                                                    VStack {
                                                        Text(String(localized: "HomeView_add_friends_label"))
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.accentColor)
                                                            .padding(.top, screenHeight * 0.07)
                                                        
                                                        Spacer()
                                                    }
                                                }
                                            } else {
                                                VStack {
                                                    Text(String(localized: "HomeView_add_friends_label"))
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.accentColor)
                                                        .padding(.top, screenHeight * 0.07)
                                                    
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    .offset(y: -screenHeight * 0.12)
                                }
                                .padding(.top, screenHeight * 0.001)
                            }
                        }
                    }
                }
//                .navigationBarColor(backgroundColor: colorScheme == .light ? .white : .black, titleColor: colorScheme == .light ? .black : .white)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Image(uiImage: UIImage(named: colorScheme == .dark ? "FitVeinIconDark" : "FitVeinIconLight")!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SearchFriendsView().environmentObject(homeViewModel).environmentObject(profileViewModel).ignoresSafeArea(.keyboard)) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.accentColor)
                        }
                        .disabled(!networkManager.isConnected)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: NotificationsView()) {
                            Image(systemName: "bell")
                                .foregroundColor(.accentColor)
                        }
                        .disabled(!networkManager.isConnected)
                    }
                }
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private func calculatePostFrameHeightMultiplier(post: Post) -> Double {
        let textCount = post.text.count
        let photoURL = post.photoURL
        if textCount <= 50 {
            if photoURL != nil {
                return 0.8
            } else {
                return 0.29
            }
        } else if textCount > 50 && textCount <= 100 {
            if photoURL != nil {
                return 0.83
            } else {
                return 0.34
            }
        } else if textCount > 100 && textCount <= 150 {
            if photoURL != nil {
                return 0.85
            } else {
                return 0.36
            }
        } else {
            if photoURL != nil {
                return 0.92
            } else {
                return 0.43
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeView()
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
