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
    
    @State private var showPostOptions = false
    @State private var showEditPostSheet = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var commentText = ""
    
    @FocusState private var isCommentTextFieldFocused
    
    @State private var isCommentEditTextFieldFocused = false
    
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        let screenWidth = UIScreen.screenWidth
        let screenHeight = UIScreen.screenHeight
        
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HomeTabCommentsViewPostView(post: post).environmentObject(homeViewModel).environmentObject(profileViewModel)
//                            .frame(width: screenWidth, height: post.photoURL == nil ? screenHeight * 0.3 : screenHeight * 0.9)
//                            .padding(.bottom, screenHeight * 0.1)
                    
                    
                    if let postComments = homeViewModel.postsComments[post.id] {
                        LazyVStack(spacing: screenHeight * 0.025) {
                            ForEach(postComments) { comment in
                                HomeTabCommentsView(post: post, comment: comment, isCommentEditTextFieldFocusedBool: $isCommentEditTextFieldFocused).environmentObject(homeViewModel).environmentObject(profileViewModel)
    //                                    .frame(width: screenWidth, height: screenHeight * 0.225)
    //                                    .padding(.bottom, screenHeight * calculateCommentFrameLength(comment: comment))
                            }
                        }
                    }
                }
            }
            .padding(.top, screenHeight * 0.001)
            .padding(.bottom, isCommentTextFieldFocused ? screenHeight * 0.23 : (isCommentEditTextFieldFocused ? screenHeight * 0.165 : 0.1))
            
            HStack {
                TextField(String(localized: "CommentView_comment_text_field_label"), text: $commentText)
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
                    Text(String(localized: "CommentView_send_comment_button"))
                        .foregroundColor(.white)
                })
                    .disabled(self.commentText.count > 200)
                    .frame(width: screenWidth * 0.18, height: screenHeight * 0.04)
                    .background(RoundedRectangle(cornerRadius: 25, style: .continuous).foregroundColor(self.commentText.count > 200 ? .gray : .accentColor))
            }
            .frame(width: screenWidth * 0.95, height: screenHeight * 0.04)
            .background(RoundedRectangle(cornerRadius: 25, style: .continuous).stroke().foregroundColor(.accentColor))
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
            .padding(.bottom, screenHeight * 0.08)
            .offset(y: isCommentTextFieldFocused ? -screenHeight * 0.23 : 0)
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
//                    .frame(width: screenWidth * 0.08, height: screenHeight * 0.08)
//                    .padding(.leading, screenWidth * 0.05)
                    
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
                    .font(.system(size: screenHeight * 0.017))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if self.homeViewModel.sessionStore.currentUser!.uid == post.authorID {
                    Button(action: {
                        withAnimation {
                            showPostOptions.toggle()
                        }
                    }, label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.accentColor)
//                            .padding(.trailing, screenWidth * 0.03)
                    })
                }
            }
        }
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
        .background(.ultraThinMaterial, in: Rectangle())
    }
    
//    private func calculateCommentViewPostPadding(post: Post) -> Double {
//        let postTextCount = post.text.count
//        let pos
//    }
    
    private func calculateCommentFrameLength(comment: Comment) -> Double {
        let commentTextCount = comment.text.count
        if commentTextCount <= 50 {
            return -0.01
        } else if commentTextCount > 50 && commentTextCount <= 100 {
            return 0.05
        } else if commentTextCount > 100 && commentTextCount <= 150 {
            return 0.1
        } else {
            return 0.128
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
