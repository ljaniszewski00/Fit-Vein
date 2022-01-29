//
//  HomeTabSubViewShareView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import SwiftUI

struct HomeTabSubViewShareView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var medalsViewModel: MedalsViewModel
    
    @State private var showAddPostSheet = false
    
    var body: some View {
        let screenWidth = UIScreen.screenWidth
        let screenHeight = UIScreen.screenHeight
        
        VStack {
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
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .frame(width: screenWidth * 0.05, height: screenHeight * 0.05)
                .padding(.trailing, screenWidth * 0.04)

                Text(String(localized: "HomeView_share"))
                    .foregroundColor(Color(uiColor: .systemGray))
                    .font(.system(size: screenHeight * 0.02))
                
                Spacer()
            }
            .padding()
            .padding(.leading)
            .onTapGesture {
                withAnimation {
                    showAddPostSheet.toggle()
                }
            }
            
            Divider()

            Text(String(localized: "HomeView_friends_activity"))
                .foregroundColor(.accentColor)
                .font(.system(size: screenHeight * 0.03, weight: .bold))
                .padding()
                .background(Rectangle().foregroundColor(Color(uiColor: .systemGray6)).frame(width: screenWidth))
                
        }
        .sheet(isPresented: $showAddPostSheet) {
            AddPostView().environmentObject(homeViewModel).environmentObject(profileViewModel).environmentObject(medalsViewModel).ignoresSafeArea(.keyboard)
        }
    }
}

struct HomeTabSubViewShareView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewShareView()
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
