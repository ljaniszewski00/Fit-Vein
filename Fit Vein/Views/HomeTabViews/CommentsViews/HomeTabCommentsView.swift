//
//  HomeTabCommentsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 13/01/2022.
//

import SwiftUI

struct HomeTabCommentsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @State private var showCommentOptions = false
    @State private var showEditView = false
    
    @State private var commentEditMode = false
    
    @State private var commentNewText = ""
    
    @State private var error = false
    
    private var post: Post
    private var comment: Comment
    
    init(post: Post, comment: Comment) {
        self.post = post
        self.comment = comment
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Group {
                        if let profilePictureURL = self.homeViewModel.postsCommentsAuthorsProfilePicturesURLs[comment.authorID] {
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
                    .frame(width: screenWidth * 0.1, height: screenHeight * 0.5)
                    .padding(.leading, screenWidth * 0.08)
                    .padding(.trailing, screenWidth * 0.01)
                    
                    VStack(spacing: screenHeight * 0.1) {
                        HStack {
                            Group {
                                Text(comment.authorFirstName)
                                    .fontWeight(.bold)
                                Text("•")
                                Text(comment.authorUsername)
                                Spacer()

                                if let profile = profileViewModel.profile {
                                    if profile.id == comment.authorID {
                                        Button(action: {
                                            withAnimation {
                                                self.showCommentOptions = true
                                            }
                                        }, label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundColor(.accentColor)
                                                .padding(.trailing, screenWidth * 0.05)
                                        })

                                    }
                                }
                            }
                        }
                        
                        if commentEditMode {
                            TextField("", text: $commentNewText)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(comment.text)
                                .font(.system(size: screenHeight * 0.1))
                                .fixedSize(horizontal: false, vertical: false)
                        }
                        
                        HStack {
                            if error {
                                HStack(spacing: 0) {
                                    LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                        .frame(width: screenWidth * 0.05, height: screenHeight * 0.15)
                                    Text("Error editing comment. Please, try again later.\n")
                                        .foregroundColor(.red)
                                        .font(.system(size: screenWidth * 0.025, weight: .bold))
                                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.2)
                                }
                            } else {
                                Group {
                                    Text(getShortDate(longDate: comment.addDate))
                                        .foregroundColor(Color(uiColor: .systemGray2))
                                    Spacer()
                                }
                                
                                if commentEditMode {
                                    Button(action: {
                                        withAnimation {
                                            self.commentEditMode = false
                                        }
                                    }, label: {
                                        Text("Cancel")
                                            .font(.system(size: screenHeight * 0.07))
                                            .frame(width: screenWidth * 0.12, height: screenHeight * 0.1)
                                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke())
                                    })
                                    
                                    Button(action: {
                                        self.error = false
                                        withAnimation {
                                            self.homeViewModel.editComment(commentID: comment.id, text: commentNewText) { success in
                                                if success {
                                                    self.commentEditMode = false
                                                } else {
                                                    withAnimation {
                                                        self.error = true
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                        withAnimation {
                                                            self.error = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }, label: {
                                        Text("Update")
                                            .foregroundColor(.white)
                                            .font(.system(size: screenHeight * 0.07))
                                            .frame(width: screenWidth * 0.12, height: screenHeight * 0.1)
                                            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).foregroundColor(.accentColor))
                                            .disabled(commentNewText.count > 200)
                                    })
                                } else {
                                    HStack {
                                        if let reactionsUsersIDs = comment.reactionsUsersIDs {
                                            if reactionsUsersIDs.contains(self.profileViewModel.profile!.id) {
                                                Button(action: {
                                                    self.homeViewModel.removeReactionFromComment(userID: self.profileViewModel.profile!.id, commentID: comment.id) { success in }
                                                }, label: {
                                                    HStack {
                                                        Image(systemName: "hand.thumbsup.fill")
                                                    }
                                                    .foregroundColor(.accentColor)
                                                    .frame(width: screenWidth * 0.05, height: screenHeight * 0.05)
                                                })

                                            } else {
                                                Button(action: {
                                                    self.homeViewModel.reactToComment(userID: self.profileViewModel.profile!.id, commentID: comment.id) { success in }
                                                }, label: {
                                                    HStack {
                                                        Image(systemName: "hand.thumbsup")
                                                    }
                                                    .foregroundColor(.accentColor)
                                                })
                                            }
                                        } else {
                                            Button(action: {
                                                self.homeViewModel.reactToComment(userID: self.profileViewModel.profile!.id, commentID: comment.id) { success in }
                                            }, label: {
                                                HStack {
                                                    Image(systemName: "hand.thumbsup")
                                                }
                                                .foregroundColor(.accentColor)
                                            })
                                        }

                                        if comment.reactionsUsersIDs != nil {
                                            if comment.reactionsUsersIDs!.count != 0 {
                                                Text("\(comment.reactionsUsersIDs!.count)")
                                            }
                                        }
                                    }
                                    .padding(.trailing, screenWidth * 0.05)
                                }
                            }
                        }
                    }
                    .padding()
                    .font(.system(size: screenHeight * 0.08))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .padding(.trailing)
                }
            }
            .frame(width: screenWidth, height: screenHeight)
            .confirmationDialog("What do you want to do with the selected comment?", isPresented: $showCommentOptions, titleVisibility: .visible) {
                Button("Edit") {
                    withAnimation {
                        self.commentNewText = self.comment.text
                        self.commentEditMode = true
                    }
                }

                Button("Delete", role: .destructive) {
                    self.homeViewModel.deleteComment(postID: post.id, commentID: comment.id) { success in }
                }
            }
        }
    }
}

struct HomeTabCommentsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let comments = [Comment(id: "id1", authorID: "1", postID: "1", authorFirstName: "Maciej", authorUsername: "maciej.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Good job!", reactionsUsersIDs: ["2", "3"]), Comment(id: "id2", authorID: "3", postID: "1", authorFirstName: "Kamil", authorUsername: "kamil.j223", authorProfilePictureURL: "nil", addDate: Date(), text: "Let's Go!", reactionsUsersIDs: ["1", "3"])]
        let post = Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: comments)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                NavigationView {
                    HomeTabCommentsView(post: post, comment: post.comments![0])
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
