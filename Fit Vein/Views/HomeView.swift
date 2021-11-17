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
    
    @State var showPlaceholderText: Bool = true
    @State var postText: String = ""
    
    init(homeViewModel: HomeViewModel, profileViewModel: ProfileViewModel) {
        self.homeViewModel = homeViewModel
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                ScrollView(.vertical) {
                    VStack {
                        VStack {
                            HStack {
                                if profileViewModel.profilePicturePhotoURL != nil {
                                    AsyncImage(url: profileViewModel.profilePicturePhotoURL!) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 50))
                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                    } placeholder: {
                                        Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 50))
                                            .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                    }
                                } else {
                                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 50))
                                        .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                }
                                
                                ZStack {
                                    TextEditor(text: $postText)
                                        .onTapGesture {
                                            showPlaceholderText = false
                                        }
                                    Text("What do you want to share?")
                                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
                                        .opacity(showPlaceholderText ? 100 : 0)
                                }
                                .frame(width: screenWidth * 0.8, height: screenHeight * 0.15)
                            }
                            .padding(.leading, screenWidth * 0.05)
                            
                            Divider()
                            
                            HStack(spacing: 0) {
                                Button(action: {
//                                    homeViewModel.addPost(author: profileViewModel.profile!, text: postText)
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
                                    self.postText = ""
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
                            
                            if homeViewModel.posts != nil {
                                ForEach(homeViewModel.posts!) { post in
                                    VStack {
                                        Rectangle()
                                            .foregroundColor(Color(uiColor: .systemGray6))
                                            .frame(width: screenWidth, height: screenHeight * 0.02)
                                        
                                        HStack {
                                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 50))
                                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                                .padding(.horizontal, screenWidth * 0.05)
                                            
                                            VStack {
                                                HStack {
                                                    Text(post.author.firstName)
                                                        .fontWeight(.bold)
                                                    Text("•")
                                                    Text(post.author.username)
                                                    Spacer()
                                                    
                                                    if profileViewModel.profile != nil {
                                                        if profileViewModel.profile!.id == post.author.id {
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
                                Text("Nothing to show")
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
        .onAppear {
            self.homeViewModel.setup(sessionStore: sessionStore)
            self.profileViewModel.setup(sessionStore: sessionStore)
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
