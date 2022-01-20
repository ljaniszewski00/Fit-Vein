//
//  HomeTabSubViewPostsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import SwiftUI

struct HomeTabSubViewPostsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                VStack {
                    HomeTabSubViewPostDetailsView(currentUserID: self.profileViewModel.profile!.id, post: post)
                        .environmentObject(homeViewModel).environmentObject(profileViewModel)
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    HStack {
                        if post.reactionsUsersIDs != nil {
                            if post.reactionsUsersIDs!.count != 0 {
                                Image(systemName: post.reactionsUsersIDs!.contains(self.profileViewModel.profile!.id) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundColor(.accentColor)
                                    .padding(.leading, screenWidth * 0.05)

                                Text("\(post.reactionsUsersIDs!.count)")
                            }

                        }

                        Spacer()

                        if let postComments = homeViewModel.postsComments[post.id] {
                            Text("\(postComments.count) \(String(localized: "HomeView_post_comments_number"))")
                                .padding(.trailing, screenWidth * 0.05)
                        }
                    }
                }

                VStack {
                    HStack(spacing: 0) {
                        Spacer()

                        if let reactionsUsersIDs = profileViewModel.profile!.reactedPostsIDs {
                            Button(action: {
                                withAnimation {
                                    if reactionsUsersIDs.contains(post.id) {
                                        self.homeViewModel.removeReactionFromPost(postID: post.id)  { success in }
                                    } else {
                                        self.homeViewModel.reactToPost(postID: post.id)  { success in }
                                    }
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "hand.thumbsup")
                                        .symbolVariant(reactionsUsersIDs.contains(post.id) ? .fill : .none)
                                    Text(String(localized: "HomeView_like_button"))
                                }
                                .foregroundColor(reactionsUsersIDs.contains(post.id) ? .green : (colorScheme == .dark ? .white : .black))
                            })
                        } else {
                            Button(action: {
                                withAnimation {
                                    self.homeViewModel.reactToPost(postID: post.id)  { success in }
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "hand.thumbsup")
                                    Text(String(localized: "HomeView_like_button"))
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            })
                        }
                        
                        Spacer()

                        Divider()
                        
                        Spacer()

                        NavigationLink(destination: PostCommentsView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel).ignoresSafeArea(.keyboard)) {
                            HStack {
                                Image(systemName: "bubble.left")
                                Text(String(localized: "HomeView_comment_button"))
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        NavigationLink(destination: EmptyView()) {
                             EmptyView()
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: screenHeight * 0.06)
                .padding(.vertical)
                .background(.ultraThinMaterial, in: Rectangle())
            }
        }
    }
}

struct HomeTabSubViewPostsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewPostsView(post: homeViewModel.posts![0])
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
