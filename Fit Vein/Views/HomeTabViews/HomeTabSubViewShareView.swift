//
//  HomeTabSubViewShareView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import SwiftUI

struct HomeTabSubViewShareView: View {
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @ObservedObject private var sheetManager: SheetManager
    
    init(sheetManager: SheetManager) {
        self.sheetManager = sheetManager
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
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
                    .frame(width: screenWidth * 0.2, height: screenHeight * 0.2)

                    Text("What do you want to share?")
                        .frame(width: screenWidth * 0.6, height: screenHeight * 0.1)
                }
                .padding(.leading, screenWidth * 0.05)
                .frame(width: screenWidth, height: screenHeight * 0.15)
                .onTapGesture {
                    withAnimation {
                        sheetManager.whichSheet = .addView
                        sheetManager.showSheet.toggle()
                    }
                }

                Divider()

                HStack(spacing: 0) {

                }

                Divider()

                HStack {
                    Text("Your friends activity")
                        .foregroundColor(.accentColor)
                        .font(.system(size: screenHeight * 0.04, weight: .bold))
                        .background(Rectangle().foregroundColor(Color(uiColor: .systemGray6)).frame(width: screenWidth, height: screenHeight * 0.08))
                }
                .padding()
            }
        }
        
    }
}

struct HomeTabSubViewShareView_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = ProfileViewModel(forPreviews: true)
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                HomeTabSubViewShareView(sheetManager: SheetManager())
                    .environmentObject(profileViewModel)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
