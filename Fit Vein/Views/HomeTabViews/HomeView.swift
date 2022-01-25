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
        let screenWidth = UIScreen.screenWidth
        let screenHeight = UIScreen.screenHeight
        
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
                            ScrollView(.vertical, showsIndicators: false) {
                                HomeTabSubViewShareView().environmentObject(homeViewModel).environmentObject(profileViewModel)

                                Group {
                                    if let posts = homeViewModel.posts {
                                        if posts.count != 0 {
                                            LazyVStack {
                                                ForEach(posts) { post in
                                                    HomeTabSubViewPostsView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
                                                        .background(Color(uiColor: .systemGray6), in: RoundedRectangle(cornerRadius: 10))
                                                }
                                            }
                                            .padding(.bottom, screenHeight * 0.07)
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
                            }
                            .padding(.top, screenHeight * 0.001)
                        }
                    }
                }
            }
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
