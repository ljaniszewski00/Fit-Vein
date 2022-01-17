//
//  PostCommentsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 26/12/2021.
//

import SwiftUI

struct PostCommentsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var commentText = ""
    
    @FocusState private var isCommentTextFieldFocused
    
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                ScrollView(.vertical) {
                    HomeTabCommentsViewPostView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
                        .frame(width: screenWidth, height: screenHeight * 0.2)
                    
                    if let postComments = homeViewModel.postsComments[post.id] {
                        ForEach(postComments) { comment in
                            HomeTabCommentsView(post: post, comment: comment).environmentObject(homeViewModel).environmentObject(profileViewModel)
                                .frame(width: screenWidth, height: screenHeight * 0.2)
                        }
                    }
                }
                .padding(.top, screenHeight * 0.001)
                
                HStack {
                    TextField("Comment", text: $commentText)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .focused($isCommentTextFieldFocused)
                        .padding(.leading)
                    
                    Spacer()

                    Button(action: {
                        withAnimation {
                            self.homeViewModel.commentPost(postID: post.id, authorID: self.profileViewModel.profile!.id, authorFirstName: self.profileViewModel.profile!.firstName, authorLastName: self.profileViewModel.profile!.username, authorProfilePictureURL: self.profileViewModel.profile!.profilePictureURL != nil ? self.profileViewModel.profile!.profilePictureURL! : "User has no profile picture", text: commentText)  { success in
                                self.commentText = ""
                            }
                        }
                    }, label: {
                        Text("Send")
                            .foregroundColor(.white)
                    })
                        .disabled(self.commentText.count > 200)
                        .frame(width: screenWidth * 0.18, height: screenHeight * 0.05)
                        .background(RoundedRectangle(cornerRadius: 25, style: .continuous).foregroundColor(self.commentText.count > 200 ? .gray : .accentColor))
                }
                .frame(width: screenWidth * 0.95, height: screenHeight * 0.05)
                .background(RoundedRectangle(cornerRadius: 25, style: .continuous).stroke().foregroundColor(.accentColor))
                .padding(.bottom, screenHeight * 0.1)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(width: screenWidth * 0.08, height: screenHeight * 0.08)
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
            
            .background(.ultraThinMaterial, in: Rectangle())
        }
    }
}

struct PostCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let comments = [Comment(id: "id1", authorID: "1", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Good job!", reactionsUsersIDs: ["2", "3"]), Comment(id: "id2", authorID: "3", postID: "1", authorFirstName: "Kamil", authorUsername: "kamil.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Let's Go!", reactionsUsersIDs: ["1", "3"])]
        let post = Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: comments)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                NavigationView {
                    PostCommentsView(post: post)
                        .environmentObject(homeViewModel)
                        .environmentObject(profileViewModel)
                        .preferredColorScheme(colorScheme)
                        .previewDevice(PreviewDevice(rawValue: deviceName))
                        .previewDisplayName(deviceName)
                }
            }
        }
    }
}