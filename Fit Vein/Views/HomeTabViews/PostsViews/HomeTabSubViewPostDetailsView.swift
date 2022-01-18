//
//  HomeTabSubViewPostDetailsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import SwiftUI

struct HomeTabSubViewPostDetailsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @ObservedObject private var sheetManager: SheetManager
    @State private var showPostOptions = false
    
    private var currentUserID: String
    private var postID: String
    private var postAuthorUserID: String
    private var postAuthorProfilePictureURL: URL?
    private var postAuthorFirstName: String
    private var postAuthorUsername: String
    private var postAddDate: Date
    private var postText: String
    
    init(sheetManager: SheetManager, currentUserID: String, postID: String, postAuthorUserID: String, postAuthorProfilePictureURL: URL?, postAuthorFirstName: String, postAuthorUsername: String, postAddDate: Date, postText: String) {
        self.sheetManager = sheetManager
        self.currentUserID = currentUserID
        self.postID = postID
        self.postAuthorUserID = postAuthorUserID
        self.postAuthorProfilePictureURL = postAuthorProfilePictureURL
        self.postAuthorFirstName = postAuthorFirstName
        self.postAuthorUsername = postAuthorUsername
        self.postAddDate = postAddDate
        self.postText = postText
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    Group {
                        if let profilePictureURL = self.postAuthorProfilePictureURL {
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
                    .frame(width: screenWidth * 0.12, height: screenHeight * 0.12)
                    
                    
                    VStack {
                        HStack {
                            Text(postAuthorFirstName)
                                .fontWeight(.bold)
                            Text("•")
                            Text(postAuthorUsername)
                            Spacer()

                            if currentUserID == postAuthorUserID {
                                Button(action: {
                                    withAnimation {
                                        self.showPostOptions = true
                                    }
                                }, label: {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.accentColor)
                                        .padding(.trailing, screenWidth * 0.05)
                                })

                            }
                        }
                        .padding(.bottom, screenHeight * 0.001)

                        HStack {
                            Text(getShortDate(longDate: postAddDate))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, screenHeight * 0.03)
                
                Text(postText)
                    .fixedSize(horizontal: false, vertical: false)
                    .padding()
                
                Spacer()
            }
            .padding()
            .frame(width: screenWidth, height: screenHeight)
            .confirmationDialog(String(localized: "HomeView_confirmation_dialog_text"), isPresented: $showPostOptions, titleVisibility: .visible) {
                Button(String(localized: "HomeView_confirmation_dialog_edit")) {
                    sheetManager.postID = postID
                    sheetManager.postText = postText
                    sheetManager.whichSheet = .editView
                    sheetManager.showSheet.toggle()
                }
                
                Button(String(localized: "HomeView_confirmation_dialog_delete"), role: .destructive) {
                    self.homeViewModel.deletePost(postID: postID) { success in }
                }
                
                Button(String(localized: "HomeView_confirmation_dialog_cancel"), role: .cancel) {}
            }
        }
    }
}

struct HomeTabSubViewPostDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let sheetManager = SheetManager()
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewPostDetailsView(sheetManager: sheetManager, currentUserID: "id1", postID: "id1", postAuthorUserID: "id1", postAuthorProfilePictureURL: nil, postAuthorFirstName: "jan", postAuthorUsername: "jan23.d", postAddDate: Date(), postText: "post")
                    .environmentObject(homeViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
