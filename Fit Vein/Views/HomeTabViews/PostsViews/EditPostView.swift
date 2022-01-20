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
    
    private var postID: String
    private var postText: String
    @State private var postTextEdited = ""
    
    @State private var success = false
    @State private var error = false
    
    init(postID: String, postText: String) {
        self.postID = postID
        self.postText = postText
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                ScrollView(.vertical) {
                    HStack {
                        Group {
                            if let profilePictureURL = profileViewModel.profilePicturePhotoURL {
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
                        HStack {
                            LottieView(name: "success2", loopMode: .loop, contentMode: .scaleAspectFit)
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
                        HStack {
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
                        .offset(y: -screenHeight * 0.05)
                    } else {
                        HStack {
                            Text(String(localized: "EditPostView_share"))
                                .foregroundColor(Color(uiColor: .systemGray3))
                                .padding()
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
                    
                    Spacer()
                }
                .onAppear {
                    self.postTextEdited = self.postText
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
                            self.homeViewModel.editPost(postID: postID, text: postTextEdited) { success in
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
                                    .foregroundColor(self.postTextEdited.count <= 200 ? .accentColor : .gray)
                                Text(String(localized: "EditPostView_save_button"))
                                    .foregroundColor(Color(uiColor: .systemGray5))
                                    .fontWeight(.bold)
                            }
                            .frame(width: screenWidth * 0.2, height: screenHeight * 0.04)
                        })
                            .disabled(self.postTextEdited.count > 200)
                    }
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
                EditPostView(postID: "id1", postText: "text")
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
