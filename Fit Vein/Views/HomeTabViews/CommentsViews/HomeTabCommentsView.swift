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
    
    @FocusState private var isCommentEditTextFieldFocused
    
    @Binding private var isCommentEditTextFieldFocusedBool: Bool
    
    private var post: Post
    private var comment: Comment
    
    init(post: Post, comment: Comment, isCommentEditTextFieldFocusedBool: Binding<Bool>) {
        self.post = post
        self.comment = comment
        self._isCommentEditTextFieldFocusedBool = isCommentEditTextFieldFocusedBool
    }
    
    var body: some View {
        let screenWidth = UIScreen.screenWidth
        let screenHeight = UIScreen.screenHeight
        
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
            .frame(width: screenWidth * 0.12, height: screenHeight * 0.1)
            .padding(.leading, screenWidth * 0.08)
            
            VStack {
                HStack {
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
                .font(.system(size: screenHeight * 0.016))
                
                Group {
                    if commentEditMode {
                        TextField("", text: $commentNewText)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(.leading)
                            .focused($isCommentEditTextFieldFocused)
                            .onChange(of: isCommentEditTextFieldFocused) { newValue in
                                self.isCommentEditTextFieldFocusedBool = newValue
                            }
                            .frame(width: screenWidth * 0.68, height: screenHeight * 0.04)
                            .background(RoundedRectangle(cornerRadius: 25, style: .continuous).stroke().foregroundColor(.accentColor))
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                    } else {
                        Text(comment.text)
                            .font(.system(size: screenHeight * 0.018))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, screenHeight * 0.01)
                
                HStack {
                    if error {
                        HStack(spacing: 0) {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFit)
                                .frame(width: screenWidth * 0.1, height: screenHeight * 0.04)
                            Text(String(localized: "CommentView_edit_comment_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.028, weight: .bold))
                        }
                    } else {
                        Group {
                            Text(getShortDate(longDate: comment.addDate))
                                .font(.system(size: screenHeight * 0.016))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            Spacer()
                        }
                        
                        if commentEditMode {
                            Button(action: {
                                withAnimation {
                                    self.commentEditMode = false
                                    isCommentEditTextFieldFocusedBool = false
                                }
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color(uiColor: UIColor(red: 255, green: 204, blue: 209)))
                                    
                                    HStack {
                                        Text(String(localized: "CommentView_edit_comment_cancel_button"))
                                            .font(.system(size: screenHeight * 0.012, weight: .bold))
                                            .foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108)))
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(width: screenWidth * 0.17, height: screenHeight * 0.03)
                            })
                            
                            Button(action: {
                                self.error = false
                                withAnimation {
                                    self.homeViewModel.editComment(commentID: comment.id, text: commentNewText) { success in
                                        if success {
                                            self.commentEditMode = false
                                            isCommentEditTextFieldFocusedBool = false
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
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color(uiColor: UIColor(red: 180, green: 255, blue: 180)))
                                    
                                    HStack {
                                        Text(String(localized: "CommentView_send_comment_update_button"))
                                            .font(.system(size: screenHeight * 0.012, weight: .bold))
                                            .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                                            .disabled(commentNewText.count > 200)
                                    }
                                    .padding(.horizontal)
                                }
                                .frame(width: screenWidth * 0.17, height: screenHeight * 0.03)
                            })
                        } else {
                            HStack(alignment: .center) {
                                if let reactionsUsersIDs = comment.reactionsUsersIDs {
                                    if reactionsUsersIDs.contains(self.profileViewModel.profile!.id) {
                                        Button(action: {
                                            self.homeViewModel.removeReactionFromComment(userID: self.profileViewModel.profile!.id, commentID: comment.id) { success in }
                                        }, label: {
                                            HStack {
                                                Image(systemName: "hand.thumbsup.fill")
                                                    .scaledToFill()
                                            }
                                            .foregroundColor(.accentColor)
                                        })

                                    } else {
                                        Button(action: {
                                            self.homeViewModel.reactToComment(userID: self.profileViewModel.profile!.id, commentID: comment.id) { success in }
                                        }, label: {
                                            HStack {
                                                Image(systemName: "hand.thumbsup")
                                                    .scaledToFill()
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
                                                .scaledToFill()
                                        }
                                        .foregroundColor(.accentColor)
                                    })
                                }

                                if comment.reactionsUsersIDs != nil {
                                    if comment.reactionsUsersIDs!.count != 0 {
                                        Text("\(comment.reactionsUsersIDs!.count)")
                                            .foregroundColor(Color(uiColor: .systemGray2))
                                    }
                                }
                            }
                            .padding(.trailing, screenWidth * 0.05)
                        }
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .padding(.trailing)
        }
        .confirmationDialog(String(localized: "CommentView_confirmation_dialog_text"), isPresented: $showCommentOptions, titleVisibility: .visible) {
            Button(String(localized: "CommentView_confirmation_dialog_edit")) {
                withAnimation {
                    self.commentNewText = self.comment.text
                    self.commentEditMode = true
                }
            }

            Button(String(localized: "CommentView_confirmation_dialog_delete"), role: .destructive) {
                self.homeViewModel.deleteComment(postID: post.id, commentID: comment.id) { success in }
            }
            
            Button(String(localized: "CommentView_confirmation_dialog_cancel"), role: .cancel) {}
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
                    HomeTabCommentsView(post: post, comment: post.comments![0], isCommentEditTextFieldFocusedBool: .constant(false))
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
