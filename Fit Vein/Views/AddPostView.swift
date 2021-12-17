//
//  AddPostView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 17/12/2021.
//

import SwiftUI

struct AddPostView: View {
    @ObservedObject private var homeViewModel: HomeViewModel
    @ObservedObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    
    @Environment(\.dismiss) var dismiss
    
    @State private var postText = ""
    
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
                    HStack {
                        if profileViewModel.profilePicturePhotoURL != nil {
                            AsyncImage(url: profileViewModel.profilePicturePhotoURL!) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .frame(width: screenWidth * 0.2, height: screenHeight * 0.1)
                            } placeholder: {
                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 50))
                                    .frame(width: screenWidth * 0.2, height: screenHeight * 0.1)
                            }
                        } else {
                            Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                                .frame(width: screenWidth * 0.2, height: screenHeight * 0.1)
                        }
                        
                        Spacer(minLength: screenWidth * 0.05)
                        
                        VStack {
                            HStack {
                                Text(profileViewModel.profile!.firstName)
                                    .foregroundColor(.green)
                                    .font(.system(size: screenHeight * 0.03))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.top, screenHeight * 0.02)
                            
                            HStack {
                                Text(profileViewModel.profile!.username)
                                    .foregroundColor(Color(uiColor: UIColor.lightGray))
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke()
                            .foregroundColor(.green)
                            .frame(width: screenWidth * 0.95, height: screenHeight * 0.525)
                        
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $postText)
                                .padding()
                                .frame(width: screenWidth * 0.9, height: screenHeight * 0.5)
                                .cornerRadius(25)
                            
                            Text("What's up?")
                                .foregroundColor(Color(uiColor: .systemGray3))
                                .isHidden(!self.postText.isEmpty)
                        }
                    }
                    
                    
                    
                    ProgressView("Chars: \(self.postText.count) / 200", value: Double(self.postText.count), total: 200)
                        .frame(width: screenWidth * 0.3, height: screenHeight * 0.04)
                        .padding()
                        .accentColor(.green)
                    
                    Spacer()
                }
                .navigationBarTitle("Add a post", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "clear.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: screenWidth * 0.06, height: screenHeight * 0.03)
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.homeViewModel.addPost(authorID: self.profileViewModel.profile!.id, authorFirstName: self.profileViewModel.profile!.firstName, authorUsername: self.profileViewModel.profile!.username, authorProfilePictureURL: self.profileViewModel.profile!.profilePictureURL == nil ? "" : self.profileViewModel.profile!.profilePictureURL!, text: self.postText)
                            dismiss()
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(self.postText.count <= 200 ? .green : .gray)
                                Text("Post")
                                    .foregroundColor(Color(uiColor: .systemGray5))
                                    .fontWeight(.bold)
                            }
                            .frame(width: screenWidth * 0.2, height: screenHeight * 0.04)
                        })
                            .disabled(self.postText.count > 200)
                    }
                }
            }
        }
    }
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        let sessionStore = SessionStore(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                AddPostView(homeViewModel: homeViewModel, profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
