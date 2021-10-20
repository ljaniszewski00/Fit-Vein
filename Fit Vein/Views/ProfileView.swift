//
//  ProfileView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var profileViewModel: ProfileViewModel
    
    @State private var image = UIImage()
    
    @State private var shouldPresentAddActionSheet = false
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentCamera = false
    
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Text("Witaj, \(profileViewModel.profile!.firstName)")
                    Spacer()
                }
                .padding()
                .font(.largeTitle)
                
                if profileViewModel.profilePicturePhotoURL != nil {
                    AsyncImage(url: profileViewModel.profilePicturePhotoURL!) { image in
                        image
                            .resizable()
                            .frame(width: screenWidth * 0.6, height: screenHeight * 0.3)
                            .clipShape(Circle())
                            .onTapGesture {
                                self.shouldPresentAddActionSheet = true
                            }
                    } placeholder: {
                        Image(uiImage: UIImage(named: "blank-profile-hi")!)
                            .resizable()
                            .frame(width: screenWidth * 0.6, height: screenHeight * 0.3)
                            .clipShape(Circle())
                    }
                } else {
                    Image(uiImage: UIImage(named: "blank-profile-hi")!)
                        .resizable()
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.3)
                        .clipShape(Circle())
                        .onTapGesture {
                            self.shouldPresentAddActionSheet = true
                        }
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $shouldPresentImagePicker) {
                ImagePicker(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, selectedImage: self.$image)
                    .onDisappear {
                        profileViewModel.uploadPhoto(image: image)
                    }
            }
            .actionSheet(isPresented: $shouldPresentAddActionSheet) {
                ActionSheet(title: Text("Add a new photo"), message: nil, buttons: [
                    .default(Text("Take a new photo"), action: {
                         self.shouldPresentImagePicker = true
                         self.shouldPresentCamera = true
                     }),
                    .default(Text("Upload a new photo"), action: {
                         self.shouldPresentImagePicker = true
                         self.shouldPresentCamera = false
                     }),
                    ActionSheet.Button.cancel()
                ])
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore()
                
                ProfileView(profileViewModel: profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
