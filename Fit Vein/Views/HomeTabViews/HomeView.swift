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
            
            if profileViewModel.profile != nil {
                withAnimation {
                    NavigationView {
                        ScrollView(.vertical) {
                            HomeTabSubViewShareView(sheetManager: sheetManager).environmentObject(profileViewModel)
                                .frame(height: screenHeight)
                                .padding(.bottom, -screenHeight * 0.75)

                            if let posts = homeViewModel.posts {
                                if posts.count != 0 {
                                    ForEach(posts) { post in
                                        HomeTabSubViewPostsView(sheetManager: sheetManager, post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
                                            .frame(height: screenHeight)
                                            .padding(.bottom, -screenHeight * 0.6)
                                    }
                                } else {
                                    Text("Nothing to show")
                                        .foregroundColor(.accentColor)
                                }
                            } else {
                                if let followedIDs = self.profileViewModel.profile!.followedIDs {
                                    if followedIDs.count != 0 {
//                                            HomeTabPostsFetchingView()
//                                                .frame(width: screenWidth, height: screenHeight)
                                        Text("Nothing to show")
                                            .foregroundColor(.accentColor)
                                    } else {
                                        Text("Add friends to see their activity")
                                            .foregroundColor(.accentColor)
                                    }
                                } else {
                                    Text("Add friends to see their activity")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .padding(.bottom, screenHeight * 0.07)
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
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: NotificationsView()) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
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
