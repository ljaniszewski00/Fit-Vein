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
    
    private var post: Post
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ScrollView(.vertical) {
                Text(post.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, screenHeight * 0.05)
                
                Spacer()
                
                HStack {
                    if post.reactionsUsersIDs != nil {
                        if post.reactionsUsersIDs!.count != 0 {
                            Image(systemName: post.reactionsUsersIDs!.contains(self.profileViewModel.profile!.id) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(.accentColor)
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
                    if let reactionsUsersIDs = profileViewModel.profile!.reactedPostsIDs {
                        if reactionsUsersIDs.contains(post.id) {
                            Button(action: {
                                self.homeViewModel.removeReactionFromPost(postID: post.id)
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
                }
                
                Divider()
                
                if let postComments = homeViewModel.postsComments[post.id] {
                    ForEach(postComments) { comment in
                        VStack(spacing: 0) {
                            HStack {
                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.1)
                                    .padding(.leading, screenWidth * 0.05)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 25)
                                        .foregroundColor(Color(uiColor: .systemGray6))
                                    
                                    VStack(spacing: screenHeight * 0.03) {
                                        HStack {
                                            Text(comment.authorFirstName)
                                                .fontWeight(.bold)
                                            Text("•")
                                            Text(comment.authorUsername)
                                            Spacer()
                                        }
                                        
                                        Text(comment.text)
                                            .font(.system(size: screenHeight * 0.025))
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        HStack {
                                            Text(getShortDate(longDate: comment.addDate))
                                                .foregroundColor(Color(uiColor: .systemGray2))
                                            Spacer()
                                            
                                            if comment.reactionsUsersIDs != nil {
                                                if comment.reactionsUsersIDs!.count != 0 {
                                                    HStack {
                                                        Image(systemName: comment.reactionsUsersIDs!.contains(self.profileViewModel.profile!.id) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                                        Text("\(comment.reactionsUsersIDs!.count)")
                                                    }
                                                    .foregroundColor(.accentColor)
                                                }
                                            }
                                        }
                                    }
                                    .padding()
                                    .font(.system(size: screenHeight * 0.02))
                                }
                                .padding()
                            }
                            
                            HStack {
                                Spacer(minLength: screenWidth * 0.4)
                                
                                if let reactionsUsersIDs = comment.reactionsUsersIDs {
                                    if reactionsUsersIDs.contains(self.profileViewModel.profile!.id) {
                                        Button(action: {
                                            self.homeViewModel.removeReactionFromComment(userID: self.profileViewModel.profile!.id, commentID: comment.id)
                                        }, label: {
                                            HStack {
                                                Image(systemName: "hand.thumbsdown")
                                                Text("Unlike")
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.accentColor)
                                        })
                                        
                                    } else {
                                        Button(action: {
                                            self.homeViewModel.reactToComment(userID: self.profileViewModel.profile!.id, commentID: comment.id)
                                        }, label: {
                                            HStack {
                                                Image(systemName: "hand.thumbsup")
                                                Text("Like")
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(.accentColor)
                                        })
                                    }
                                } else {
                                    Button(action: {
                                        self.homeViewModel.reactToComment(userID: self.profileViewModel.profile!.id, commentID: comment.id)
                                    }, label: {
                                        HStack {
                                            Image(systemName: "hand.thumbsup")
                                            Text("Like")
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.accentColor)
                                    })
                                }
                                
                                Spacer()
                                
                                if self.profileViewModel.profile!.id == comment.authorID {
                                    Button(action: {
                                        self.homeViewModel.deleteComment(postID: post.id, commentID: comment.id)
                                    }, label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Delete")
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.red)
                                    })
                                }
                                
                                Spacer()
                                
                            }
                        }
                    }
                }
                
                Spacer(minLength: screenHeight * 0.1)
                
                HStack {
                    VStack {
                        HStack {
                            Text("Add Comment")
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                TextField("", text: $commentText)
                                    .disableAutocorrection(true)
                                    .autocapitalization(.none)
                                
                                Button(action: {
                                    self.homeViewModel.commentPost(postID: post.id, authorID: self.profileViewModel.profile!.id, authorFirstName: self.profileViewModel.profile!.firstName, authorLastName: self.profileViewModel.profile!.username, authorProfilePictureURL: self.profileViewModel.profile!.profilePictureURL != nil ? self.profileViewModel.profile!.profilePictureURL! : "User has no profile picture", text: commentText)
                                }, label: {
                                    Text("Send")
                                        .foregroundColor(.accentColor)
                                })
                            }
                            
                            Divider()
                                .background(Color.accentColor)
                        }
                        
                    }
                    .padding(.horizontal)
                }
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
