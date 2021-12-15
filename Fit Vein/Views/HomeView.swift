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
    
    @State private var postText = ""
    
    init(homeViewModel: HomeViewModel, profileViewModel: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profileViewModel
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
                                    
                                    Divider()
                                    
                                    HStack(spacing: 0) {
                                        Button(action: {
                                            if homeViewModel.sessionStore.currentUser != nil && profileViewModel.profile != nil {
                                                homeViewModel.addPost(authorID: self.sessionStore.currentUser!.uid, authorFirstName: self.profileViewModel.profile!.firstName, authorUsername: self.profileViewModel.profile!.username, authorProfilePictureURL: self.profileViewModel.profile!.profilePictureURL != nil ? self.profileViewModel.profile!.profilePictureURL! : "", text: postText)
                                            }
                                        }, label: {
                                            HStack {
                                                Image(systemName: "paperplane")
                                                Text("Post")
                                            }
                                        })
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.04)

                                        Divider()

                                        Button(action: {
                                            
                                        }, label: {
                                            HStack {
                                                Image(systemName: "xmark.circle")
                                                Text("Clear")
                                            }
                                        })
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .frame(width: screenWidth * 0.5, height: screenHeight * 0.04)
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
                                        ForEach(posts) { post in
                                            VStack {
                                                Rectangle()
                                                    .foregroundColor(Color(uiColor: .systemGray6))
                                                    .frame(width: screenWidth, height: screenHeight * 0.02)
                                                
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
                                                    
                                                    VStack {
                                                        HStack {
                                                            Text(post.authorFirstName)
                                                                .fontWeight(.bold)
                                                            Text("•")
                                                            Text(post.authorUsername)
                                                            Spacer()
                                                            
                                                            if profileViewModel.profile != nil {
                                                                if profileViewModel.profile!.id == post.authorID {
                                                                    NavigationLink(destination: EditPostView()) {
                                                                        Image(systemName: "gearshape")
                                                                    }
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
                                                    Image(systemName: "hand.thumbsup.fill")
                                                        .foregroundColor(.green)
                                                        .padding(.leading, screenWidth * 0.05)
                                                        .isHidden(post.reactionsNumber == 0)
                                                    Text("\(post.reactionsNumber)")
                                                        .isHidden(post.reactionsNumber == 0)

                                                    Spacer()

                                                    Text("\(post.commentsNumber) comments")
                                                        .isHidden(post.reactionsNumber == 0)
                                                        .padding(.trailing, screenWidth * 0.05)
                                                }
                                                
                                                Divider()
                                                
                                                HStack(spacing: 0) {
                                                    Button(action: {
                                                        // Like Functionality
                                                    }, label: {
                                                        HStack {
                                                            Image(systemName: "hand.thumbsup")
                                                            Text("Like")
                                                        }
                                                    })
                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.04)
                                                    
                                                    Divider()
                                                    
                                                    Button(action: {
                                                        // Comment Functionality
                                                    }, label: {
                                                        HStack {
                                                            Image(systemName: "bubble.left")
                                                            Text("Comment")
                                                        }
                                                    })
                                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.04)
                                                }
                                                
                                                Divider()
                                            }
                                        }
                                    } else {
                                        Text("Add friends to see their achievements")
                                            .foregroundColor(.green)
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
                                NavigationLink(destination: SearchFriendsView()) {
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
                }
            } else {
                withAnimation {
                    HomeTabFetchingView()
                        .onAppear() {
                            self.homeViewModel.setup(sessionStore: sessionStore)
                            self.homeViewModel.fetchData()
                            self.profileViewModel.setup(sessionStore: sessionStore)
                            self.profileViewModel.fetchData()
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

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore(forPreviews: true)

                HomeView(homeViewModel: homeViewModel, profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
