//
//  AddPostView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 17/12/2021.
//

import SwiftUI

struct AddPostView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var postText = ""
    
    @State private var success = false
    @State private var error = false
    
    @State private var oldImage = UIImage()
    @State private var image = UIImage()
    @State private var photoSelected = false
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
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
                            Text(String(localized: "AddPostView_success"))
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
                            Text(String(localized: "AddPostView_error"))
                                .foregroundColor(.red)
                                .font(.system(size: screenWidth * 0.035, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            Text(String(localized: "AddPostView_share"))
                                .foregroundColor(Color(uiColor: .systemGray3))
                            Spacer()
                            Text("\(postText.count) / 200")
                                .foregroundColor(Color(uiColor: .systemGray2))
                        }
                        .padding()
                    }
                    
                    TextEditor(text: $postText)
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
                                
                                Text(String(localized: !photoSelected ? "AddPostView_upload_photo" : "AddPostView_photo_selected"))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                            }
                            .frame(height: screenHeight * 0.05)
                        }
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.05)
                    })
                    
                    Spacer()
                }
                .navigationBarTitle(String(localized: "AddPostView_navigation_title"), displayMode: .inline)
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
                            self.homeViewModel.addPost(authorID: self.profileViewModel.profile!.id, authorFirstName: self.profileViewModel.profile!.firstName, authorUsername: self.profileViewModel.profile!.username, authorProfilePictureURL: self.profileViewModel.profile!.profilePictureURL == nil ? "" : self.profileViewModel.profile!.profilePictureURL!, text: self.postText, photo: photoSelected ? image : nil) { success in
                                withAnimation {
                                    if success {
                                        self.success = true
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
                                    .foregroundColor(self.postText.count <= 200 ? .accentColor : .gray)
                                Text(String(localized: "AddPostView_post_button"))
                                    .foregroundColor(colorScheme == .light ? .white : .black)
                                    .fontWeight(.bold)
                            }
                            .frame(width: screenWidth * 0.25, height: screenHeight * 0.04)
                        })
                            .disabled(self.postText.count > 200)
                    }
                }
                .sheet(isPresented: $shouldPresentImagePicker) {
                    ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                        .onDisappear {
                            if !self.image.isEqual(self.oldImage) {
                                self.oldImage = image
                                self.image = image
                                photoSelected = true
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

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)

        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                AddPostView()
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
