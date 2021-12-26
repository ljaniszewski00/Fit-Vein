//
//  PostCommentsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/12/2021.
//

import SwiftUI

struct PostCommentsView: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    
    private var post: Post
    
    init(homeViewModel: HomeViewModel, profileViewModel: ProfileViewModel, post: Post) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profileViewModel
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ScrollView(.vertical) {
                Text("Hello World!")
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
//                        This causes an error
//                        if let postAuthorProfilePictureURL = homeViewModel.postsAuthorsProfilePicturesURLs[post.id] {
//                            AsyncImage(url: postAuthorProfilePictureURL) { phase in
//                                if let image = phase.image {
//                                    image
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .clipShape(RoundedRectangle(cornerRadius: 50))
//                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
//                                } else {
//                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .clipShape(RoundedRectangle(cornerRadius: 50))
//                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
//                                }
//                            }
//                        } else {
//                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .clipShape(RoundedRectangle(cornerRadius: 50))
//                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
//                        }
//                        This causes an error
                        
                        Image(uiImage: UIImage(named: "blank-profile-hi")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .frame(width: screenWidth * 0.1, height: screenHeight * 0.1)
                            .padding(.leading, screenWidth * 0.05)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text(post.authorFirstName)
                                    .fontWeight(.bold)
                                Text("•")
                                Text(post.authorUsername)
                                Spacer()
                            }
                            
                            HStack {
                                Text(getShortDate(longDate: post.addDate))
                                    .foregroundColor(Color(uiColor: .systemGray2))
                                Spacer()
                            }
                        }
                        .font(.system(size: screenHeight * 0.02))
                    }
                }
            }
        }
    }
}

struct PostCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let sessionStore = SessionStore(forPreviews: true)
        let commentsPost1: [Comment] = [Comment(authorID: "2", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)"), Comment(authorID: "3", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej23.d", authorProfilePictureURL: "", text: "Excellent :)")]
        let post = Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, comments: commentsPost1)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                NavigationView {
                    PostCommentsView(homeViewModel: homeViewModel, profileViewModel: profileViewModel, post: post)
                        .preferredColorScheme(colorScheme)
                        .previewDevice(PreviewDevice(rawValue: deviceName))
                        .previewDisplayName(deviceName)
                        .environmentObject(sessionStore)
                }
            }
        }
    }
}
