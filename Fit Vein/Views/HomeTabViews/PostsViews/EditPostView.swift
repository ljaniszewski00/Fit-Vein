//
//  EditPostView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import SwiftUI

struct EditPostView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var post: Post
    
    @State private var postTextEdited = ""
    
    @State private var success = false
    @State private var error = false
    
    @State private var oldImage = UIImage()
    @State private var image = UIImage()
    @State private var photoSelected = false
    @State private var photoExists = false
    @State private var photoToBeDeleted = false
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                ScrollView(.vertical) {
                    HStack {
                        Group {
                            if let profilePicturePhoto = profileViewModel.profilePicturePhoto {
                                Image(uiImage: profilePicturePhoto)
                                    .resizable()
                            } else {
                                Image(uiImage: UIImage(named: "blank-profile-hi")!)
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 50))
                        .frame(width: screenWidth * 0.2, height: screenHeight * 0.1)
                        
                        Spacer(minLength: screenWidth * 0.05)
                        
                        VStack {
                            HStack {
                                Text(profileViewModel.profile!.firstName)
                                    .foregroundColor(.accentColor)
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
                    
                    if success {
                        HStack(alignment: .center) {
                            LottieView(name: "success2", loopMode: .playOnce, contentMode: .scaleAspectFit)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "EditPostView_success"))
                                .foregroundColor(.green)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                                .offset(y: -screenHeight * 0.01)
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else if error {
                        HStack(alignment: .center) {
                            LottieView(name: "wrongData", loopMode: .loop, contentMode: .scaleAspectFill)
                                .frame(width: screenWidth * 0.15, height: screenHeight * 0.05)
                                .padding(.leading)
                                .offset(y: -screenHeight * 0.013)
                            Text(String(localized: "EditdPostView_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Text(String(localized: "EditPostView_share"))
                                .foregroundColor(Color(uiColor: .systemGray3))
                            Spacer()
                            Text("\(postTextEdited.count) / 200")
                                .foregroundColor(Color(uiColor: .systemGray2))
                        }
                        .padding()
                    }
                    
                    TextEditor(text: $postTextEdited)
                        .padding()
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.5)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary).opacity(0.5))
                        .padding(.bottom, screenHeight * 0.02)
                    
                    Button(action: {
                        withAnimation {
                            self.shouldPresentAddActionSheet = true
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color(uiColor: UIColor(red: 180, green: 255, blue: 180)))
                            
                            HStack(alignment: .center, spacing: screenWidth * 0.03) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: screenWidth * 0.1, height: screenHeight * 0.03)
                                
                                Text(String(localized: photoExists ? (photoSelected ? "EditPostView_photo_selected" : "EditPostView_change_photo") : "EditPostView_upload_photo"))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                            .frame(height: screenHeight * 0.05)
                        }
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                    })
                    
                    Button(action: {
                        withAnimation {
                            photoExists = false
                            photoSelected = false
                            oldImage = UIImage()
                            image = UIImage()
                            photoToBeDeleted = true
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color(uiColor: UIColor(red: 255, green: 204, blue: 209)))
                            
                            HStack(alignment: .center, spacing: screenWidth * 0.03) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: screenWidth * 0.1, height: screenHeight * 0.03)
                                
                                Text(String(localized: "EditPostView_delete_photo"))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(Color(uiColor: UIColor(red: 255, green: 104, blue: 108)))
                            .frame(height: screenHeight * 0.05)
                        }
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                    })
                        .disabled(!photoExists)
                }
                .onAppear {
                    self.postTextEdited = self.post.text
                    if post.photoURL != nil {
                        self.photoExists = true
                    }
                }
                .navigationBarTitle(String(localized: "EditPostView_navigation_title"), displayMode: .inline)
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
                            withAnimation {
                                self.error = false
                                self.success = false
                            }
                            if photoToBeDeleted || photoSelected {
                                if let postPhotoURL = post.photoURL {
                                    homeViewModel.deletePostPhoto(photoURL: postPhotoURL, userID: profileViewModel.profile!.id, postID: post.id) { success in
                                        homeViewModel.removePostPhotoURLAfterDeletion(postID: post.id)
                                    }
                                }
                            }
                            
                            self.homeViewModel.editPost(postID: self.post.id, userID: self.post.authorID, text: postTextEdited, photo: self.image.isEqual(UIImage()) ? nil : self.image ) { success in
                                withAnimation {
                                    if success {
                                        self.success = true
                                        homeViewModel.fetchData()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            dismiss()
                                        }
                                    } else {
                                        self.error = true
                                    }
                                }
                            }
                        }, label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(self.postTextEdited.count <= 200 ? .accentColor : .gray)
                                Text(String(localized: "EditPostView_save_button"))
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                                    .fontWeight(.bold)
                            }
                            .frame(width: screenWidth * 0.2, height: screenHeight * 0.04)
                        })
                            .disabled(self.postTextEdited.count > 200)
                    }
                }
                .sheet(isPresented: $shouldPresentImagePicker) {
                    ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                        .onDisappear {
                            if !self.image.isEqual(self.oldImage) {
                                self.oldImage = image
                                self.image = image
                                photoSelected = true
                                photoExists = true
                            }
                        }
                }
                .actionSheet(isPresented: $shouldPresentAddActionSheet) {
                    ActionSheet(title: Text(String(localized: "ProfileView_change_photo_confirmation_dialog_text")), message: nil, buttons: [
                        .default(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_take_photo_button")), action: {
                             self.shouldPresentImagePicker = true
                             self.shouldPresentCamera = true
                         }),
                        .default(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_upload_photo_button")), action: {
                             self.shouldPresentImagePicker = true
                             self.shouldPresentCamera = false
                         }),
                        .cancel(Text(String(localized: "ProfileView_change_photo_confirmation_dialog_cancel_button")))
                    ])
                }
            }
        }
    }
}

struct EditPostView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                EditPostView(post: Post(id: "1", authorID: "1", authorFirstName: "Jan", authorUsername: "jan23.d", authorProfilePictureURL: "", addDate: Date(), text: "Did this today!", reactionsUsersIDs: nil, commentedUsersIDs: nil, comments: nil))
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
