//
//  HomeTabSubViewPostDetailsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import SwiftUI

struct HomeTabSubViewPostDetailsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @State private var showPostOptions = false
    @State private var showEditPostSheet = false
    
    private var currentUserID: String
    private var post: Post
    
    init(currentUserID: String, post: Post) {
        self.currentUserID = currentUserID
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Group {
                        if let profilePictureURL = self.homeViewModel.postsAuthorsProfilePicturesURLs[post.id] {
                            AsyncImage(url: profilePictureURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                } else {
                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                        .resizable()
                                }
                            }
                        } else {
                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                .resizable()
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    .frame(width: screenWidth * 0.12, height: screenHeight * 0.12)
                    
                    VStack {
                        HStack {
                            Text(post.authorFirstName)
                                .fontWeight(.bold)
                            Text("•")
                            Text(post.authorUsername)
                            Spacer()

                            if currentUserID == post.authorID {
                                Button(action: {
                                    withAnimation {
                                        showPostOptions.toggle()
                                    }
                                }, label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.accentColor)
                                        .padding(.trailing, screenWidth * 0.05)
                                })

                            }
                        }
                        .padding(.bottom, screenHeight * 0.001)

                        HStack {
                            Text(getShortDate(longDate: post.addDate))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Text(post.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .padding(.bottom, screenHeight * calculatePostTextBottomPaddingHeightMultiplier(post: post))
                
                if let post = self.homeViewModel.getCurrentPostDetails(postID: post.id) {
                    if let postPhotoURL = post.photoURL {
                        Group {
                            if let postPictureURL = self.homeViewModel.postsPicturesURLs[post.id] {
                                AsyncImage(url: postPictureURL) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                        .frame(width: screenWidth * 0.9, height: screenHeight)
                    }
                }
            }
            .padding()
            .confirmationDialog(String(localized: "HomeView_confirmation_dialog_text"), isPresented: $showPostOptions, titleVisibility: .visible) {
                Button(String(localized: "HomeView_confirmation_dialog_edit")) {
                    showEditPostSheet.toggle()
                }

                Button(String(localized: "HomeView_confirmation_dialog_delete"), role: .destructive) {
                    self.homeViewModel.deletePost(postID: post.id, postPictureURL: post.photoURL) { success in }
                }

                Button(String(localized: "HomeView_confirmation_dialog_cancel"), role: .cancel) {}
            }
            .sheet(isPresented: $showEditPostSheet) {
                EditPostView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel).ignoresSafeArea(.keyboard)
            }
        }
    }
    
    private func calculatePostTextBottomPaddingHeightMultiplier(post: Post) -> Double {
        let textCount = post.text.count
        let photoURL = post.photoURL
        if photoURL == nil {
            return 0
        } else {
            if textCount <= 50 {
                return 0.22
            } else if textCount > 50 && textCount <= 100 {
                return 0.11
            } else if textCount > 100 && textCount <= 150 {
                return 0.1
            } else {
                return 0.05
            }
        }
    }
}

struct HomeTabSubViewPostDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let comments = [Comment(id: "id1", authorID: "1", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Good job!", reactionsUsersIDs: ["2", "3"]), Comment(id: "id2", authorID: "3", postID: "1", authorFirstName: "Kamil", authorUsername: "kamil.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Let's Go!", reactionsUsersIDs: ["1", "3"])]
        let post = Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: comments)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewPostDetailsView(currentUserID: "id1", post: post)
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
