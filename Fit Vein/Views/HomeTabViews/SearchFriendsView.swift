//
//  SearchFriendsView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 28/10/2021.
//

import SwiftUI

struct SearchFriendsView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @EnvironmentObject private var sessionStore: SessionStore
    
    @State var searching = false
    @State var searchText = ""
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                VStack {
                    if let usersData = self.homeViewModel.usersData {
                        List {
                            ForEach(Array(usersData.keys), id: \.self) { userID in
                                HStack {
                                    Group {
                                        if let usersProfilePicturesURLs = self.homeViewModel.usersProfilePicturesURLs {
                                            AsyncImage(url: usersProfilePicturesURLs[userID]) { phase in
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
                                    .frame(width: screenWidth * 0.15, height: screenHeight * 0.15)
                                    
                                    VStack() {
                                        Spacer()
                                        
                                        if let userData = usersData[userID] {
                                            HStack {
                                                Text(userData[0])
                                                    .foregroundColor(.accentColor)
                                                    .font(.system(size: screenHeight * 0.025, weight: .bold))
                                                    .padding(.bottom, screenHeight * 0.002)
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Text(userData[1])
                                                    .foregroundColor(Color(uiColor: .systemGray3))
                                                Spacer()
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, screenWidth * 0.03)
                                    
                                    Spacer()
                                    
                                    if self.profileViewModel.profile!.followedIDs != nil {
                                        if self.profileViewModel.profile!.followedIDs!.contains(userID) {
                                            Button(action: {
                                                self.profileViewModel.unfollowUser(userID: userID) {
                                                    self.homeViewModel.fetchData()
                                                }
                                            }, label: {
                                                Image(systemName: "person.crop.circle.badge.minus")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundColor(.red)
                                                    .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                            })
                                        } else {
                                            Button(action: {
                                                self.profileViewModel.followUser(userID: userID) {
                                                    self.homeViewModel.fetchData()
                                                }
                                            }, label: {
                                                Image(systemName: "person.crop.circle.badge.plus")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundColor(.accentColor)
                                                    .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                            })
                                        }
                                    } else {
                                        Button(action: {
                                            self.profileViewModel.followUser(userID: userID) {
                                                self.homeViewModel.fetchData()
                                            }
                                        }, label: {
                                            Image(systemName: "plus.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.accentColor)
                                                .frame(width: screenWidth * 0.07, height: screenHeight * 0.035)
                                        })
                                    }
                                }
                                .frame(width: screenWidth * 0.8, height: screenHeight * 0.1)
                            }
                        }
                        .searchable(text: $searchText)
                        .listStyle(GroupedListStyle())
                    }
                }
                .navigationTitle("Follow")
                .onAppear {
                    self.homeViewModel.getAllUsersData()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct SearchFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        let homeViewModel = HomeViewModel(forPreviews: true)
        let profileViewModel = ProfileViewModel(forPreviews: true)
        
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                SearchFriendsView()
                    .environmentObject(homeViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
            }
        }
    }
}
