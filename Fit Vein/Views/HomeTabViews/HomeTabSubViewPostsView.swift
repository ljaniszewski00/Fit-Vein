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
    @ObservedObject private var sheetManager: SheetManager
    @Environment(\.colorScheme) var colorScheme
    
    private var post: Post
    
    init(sheetManager: SheetManager, post: Post) {
        self.sheetManager = sheetManager
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HomeTabSubViewPostDetailsView(sheetManager: sheetManager, currentUserID: self.profileViewModel.profile!.id, postID: post.id, postAuthorUserID: post.authorID, postAuthorProfilePictureURL: self.homeViewModel.postsAuthorsProfilePicturesURLs[post.id], postAuthorFirstName: post.authorFirstName, postAuthorUsername: post.authorUsername, postAddDate: post.addDate, postText: post.text)
                    .environmentObject(homeViewModel)
                
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
                            Text("\(postComments.count) comments")
                                .padding(.trailing, screenWidth * 0.05)
                        }
                    }

                    VStack {
                        
                        HStack(spacing: 0) {
                            Spacer()

                            if let reactionsUsersIDs = profileViewModel.profile!.reactedPostsIDs {
                                if reactionsUsersIDs.contains(post.id) {
                                    Button(action: {
                                        withAnimation {
                                            self.homeViewModel.removeReactionFromPost(postID: post.id)
                                        }
                                    }, label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsdown")
                                            Text("Unlike")
                                        }
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    })
                                } else {
                                    Button(action: {
                                        withAnimation {
                                            self.homeViewModel.reactToPost(postID: post.id)
                                        }
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
                                    withAnimation {
                                        self.homeViewModel.reactToPost(postID: post.id)
                                    }
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
    //                                    self.tabBarHidden = true
                            }.onDisappear {
    //                                    self.tabBarHidden = false
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left")
                                    Text("Comment")
                                }
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(height: screenHeight * 0.035)
                    .padding(.vertical)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                
                Spacer()
            }
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 5))
            .frame(width: screenWidth, height: screenHeight)
        }
    }
}

struct HomeTabSubViewPostsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let sheetManager = SheetManager()

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewPostsView(sheetManager: sheetManager, post: homeViewModel.posts![0])
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
