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
    
    private class SheetManager: ObservableObject {
        enum Sheet {
            case addView
            case editView
        }
        
        var postID: String?
        var postText: String?
        @Published var showSheet = false
        @Published var whichSheet: Sheet? = nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            if profileViewModel.profile != nil {
                withAnimation {
                    NavigationView {
                        ScrollView(.vertical) {
                            VStack {
                                VStack {
                                    HStack {
                                        if let profilePicturePhotoURL = profileViewModel.profilePicturePhotoURL {
                                            AsyncImage(url: profilePicturePhotoURL) { phase in
                                                if let image = phase.image {
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                                } else {
                                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                                }
                                            }
                                        } else {
                                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 50))
                                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                        }
                                        
                                        Text("What do you want to share?")
                                            .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
                                    }
                                    .padding(.leading, screenWidth * 0.05)
                                    .onTapGesture {
                                        withAnimation {
                                            sheetManager.whichSheet = .addView
                                            sheetManager.showSheet.toggle()
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    HStack(spacing: 0) {
                                        
                                    }
                                    
                                    Divider()
                                    
                                    Spacer(minLength: screenHeight * 0.05)
                                    
                                    HStack {
                                        Text("Your friends activity")
                                            .foregroundColor(.green)
                                            .font(.system(size: screenHeight * 0.04, weight: .bold))
                                            .background(Rectangle().foregroundColor(Color(uiColor: .systemGray6)).frame(width: screenWidth, height: screenHeight * 0.08))
                                    }
                                    .padding()
                                    
                                    if let posts = homeViewModel.posts {
                                        if posts.count != 0 {
                                            ForEach(posts) { post in
                                                VStack {
                                                    Rectangle()
                                                        .foregroundColor(Color(uiColor: .systemGray6))
                                                        .frame(width: screenWidth, height: screenHeight * 0.02)
                                                        .confirmationDialog("What do you want to do with the selected post?", isPresented: $showPostOptions) {
                                                            Button("Edit") {
                                                                sheetManager.postID = post.id
                                                                sheetManager.postText = post.text
                                                                sheetManager.whichSheet = .editView
                                                                sheetManager.showSheet.toggle()
                                                            }
                                                            Button("Delete", role: .destructive) {
                                                                self.homeViewModel.deletePost(postID: post.id)
                                                            }
                                                            Button("Cancel", role: .cancel) {}
                                                        }
                                                    
                                                    HStack {
                                                        Spacer()
    //                                                    This causes an error
    //                                                    if let postAuthorProfilePictureURL = homeViewModel.postsAuthorsProfilePicturesURLs[post.id] {
    //                                                        AsyncImage(url: postAuthorProfilePictureURL) { phase in
    //                                                            if let image = phase.image {
    //                                                                image
    //                                                                    .resizable()
    //                                                                    .aspectRatio(contentMode: .fit)
    //                                                                    .clipShape(RoundedRectangle(cornerRadius: 50))
    //                                                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
    //                                                            } else {
    //                                                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
    //                                                                    .resizable()
    //                                                                    .aspectRatio(contentMode: .fit)
    //                                                                    .clipShape(RoundedRectangle(cornerRadius: 50))
    //                                                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
    //                                                            }
    //                                                        }
    //                                                    } else {
    //                                                        Image(uiImage: UIImage(named: "blank-profile-hi")!)
    //                                                            .resizable()
    //                                                            .aspectRatio(contentMode: .fit)
    //                                                            .clipShape(RoundedRectangle(cornerRadius: 50))
    //                                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
    //                                                    }
    //                                                    This causes an error
                                                        
                                                        Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .clipShape(RoundedRectangle(cornerRadius: 50))
                                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                                            .padding(.leading, screenWidth * 0.05)
                                                        
                                                        VStack {
                                                            HStack {
                                                                Text(post.authorFirstName)
                                                                    .fontWeight(.bold)
                                                                Text("•")
                                                                Text(post.authorUsername)
                                                                Spacer()
                                                                
                                                                if profileViewModel.profile != nil {
                                                                    if profileViewModel.profile!.id == post.authorID {
                                                                        Button(action: {
                                                                            self.showPostOptions = true
                                                                        }, label: {
                                                                            Image(systemName: "ellipsis")
                                                                                .foregroundColor(.green)
                                                                                .padding(.trailing, screenWidth * 0.05)
                                                                        })
                                                                            
                                                                    }
                                                                }
                                                            }
                                                            .padding(.bottom, screenHeight * 0.001)
                                                            
                                                            HStack {
                                                                Text(getShortDate(longDate: post.addDate))
                                                                    .foregroundColor(Color(uiColor: .systemGray2))
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                    
                                                    Text(post.text)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                    
                                                    Spacer()
                                                    
                                                    HStack {
                                                        if post.reactionsUsersIDs != nil {
                                                            if post.reactionsUsersIDs!.count != 0 {
                                                                Image(systemName: post.reactionsUsersIDs!.contains(self.homeViewModel.sessionStore.currentUser!.uid) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                                                    .foregroundColor(.green)
                                                                    .padding(.leading, screenWidth * 0.05)
                                                                
                                                                Text("\(post.reactionsUsersIDs!.count)")
                                                                    .foregroundColor(Color(uiColor: .systemGray5))
                                                            }
                                                            
                                                        }

                                                        Spacer()
                                                        
                                                        if let postComments = homeViewModel.postsComments[post.id] {
                                                            Text("\(postComments.count) comments")
                                                                .padding(.trailing, screenWidth * 0.05)
                                                                .foregroundColor(Color(uiColor: .systemGray5))
                                                        }
                                                    }
                                                    
                                                    Divider()
                                                    
                                                    HStack(spacing: 0) {
                                                        Spacer()
                                                        
                                                        if let reactionsUsersIDs = post.reactionsUsersIDs {
                                                            if reactionsUsersIDs.contains(self.profileViewModel.profile!.id) {
                                                                Button(action: {
                                                                    self.homeViewModel.reactToPost(postID: post.id)
                                                                }, label: {
                                                                    HStack {
                                                                        Image(systemName: "hand.thumbsdown")
                                                                        Text("Unlike")
                                                                    }
                                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                                })
                                                            } else {
                                                                Button(action: {
                                                                    self.homeViewModel.reactToPost(postID: post.id)
                                                                }, label: {
                                                                    HStack {
                                                                        Image(systemName: "hand.thumbsup")
                                                                        Text("Like")
                                                                    }
                                                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                                })
                                                            }
                                                        } else {
                                                            Button(action: {
                                                                self.homeViewModel.reactToPost(postID: post.id)
                                                            }, label: {
                                                                HStack {
                                                                    Image(systemName: "hand.thumbsup")
                                                                    Text("Like")
                                                                }
                                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                            })
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Divider()
                                                        
                                                        Spacer()
                                                        
                                                        NavigationLink(destination:
                                                                        PostCommentsView(post: post)
                                                                        .environmentObject(homeViewModel)
                                                                        .environmentObject(profileViewModel)
                                                                        .onAppear {
                                                            self.tabBarHidden = true
                                                        }.onDisappear {
                                                            self.tabBarHidden = false
                                                        }) {
                                                            HStack {
                                                                Image(systemName: "bubble.left")
                                                                Text("Comment")
                                                            }
                                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    .frame(height: screenHeight * 0.035)
                                                    
                                                    Divider()
                                                }
                                            }
                                        } else {
                                            Text("Nothing to show")
                                                .foregroundColor(.green)
                                        }
                                    } else {
                                        if let followedIDs = self.profileViewModel.profile!.followedIDs {
                                            if followedIDs.count != 0 {
                                                HomeTabPostsFetchingView()
                                                    .frame(width: screenWidth, height: screenHeight)
                                            } else {
                                                Text("Add friends to see their activity")
                                                    .foregroundColor(.green)
                                            }
                                        } else {
                                            Text("Add friends to see their activity")
                                                .foregroundColor(.green)
                                        }
                                    }
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
                                        .foregroundColor(.green)
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: NotificationsView()) {
                                    Image(systemName: "bell")
                                        .foregroundColor(.green)
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
                    HomeTabFetchingView()
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
