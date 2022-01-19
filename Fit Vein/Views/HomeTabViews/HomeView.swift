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
    @EnvironmentObject private var sessionStore: SessionStore
    @EnvironmentObject private var networkManager: NetworkManager
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var sheetManager = SheetManager()
    
    @Binding var tabBarHidden: Bool
    
    @State private var showPostOptions = false
    @State private var showEditView = false
    @State private var showAddView = false
    
    @State private var showCommentsView = false
    
    init(tabBarHidden: Binding<Bool>) {
        self._tabBarHidden = tabBarHidden
    }
    
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
                                    HomeTabSubViewShareView(sheetManager: sheetManager).environmentObject(profileViewModel)
                                        .frame(height: screenHeight * 0.25)
                                        .padding(.bottom, screenHeight * 0.055)
                                        .offset(y: -screenHeight * 0.02)

                                    Group {
                                        if let posts = homeViewModel.posts {
                                            if posts.count != 0 {
                                                ForEach(posts) { post in
                                                    HomeTabSubViewPostsView(sheetManager: sheetManager, post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
                                                        .frame(height: screenHeight * 0.25)
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
                                .sheet(isPresented: $sheetManager.showSheet) {
                                    switch sheetManager.whichSheet {
                                    case .addView:
                                        AddPostView().environmentObject(homeViewModel).environmentObject(profileViewModel).environmentObject(sessionStore)
                                    case .editView:
                                        EditPostView(postID: sheetManager.postID!, postText: sheetManager.postText!).environmentObject(homeViewModel).environmentObject(profileViewModel).environmentObject(sessionStore)
                                    default:
                                        Text("No view")
                                    }
                                }
                            }
                        } else {
                            withAnimation {
                                LottieView(name: "skeleton", loopMode: .loop)
                                    .frame(width: screenWidth, height: screenHeight)
                                    .onAppear() {
            //                            self.homeViewModel.setup(sessionStore: sessionStore)
            //                            self.homeViewModel.fetchData()
            //                            self.profileViewModel.setup(sessionStore: sessionStore)
            //                            self.profileViewModel.fetchData()
                                    }
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
                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SearchFriendsView().environmentObject(homeViewModel).environmentObject(profileViewModel).environmentObject(sessionStore)) {
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
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let sessionStore = SessionStore(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeView(tabBarHidden: .constant(false))
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
