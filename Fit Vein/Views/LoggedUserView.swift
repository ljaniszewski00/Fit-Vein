//
//  LoggedUserView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 20/10/2021.
//

import SwiftUI

struct LoggedUserView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject private var homeViewModel = HomeViewModel(forPreviews: true)
    @ObservedObject private var profileViewModel = ProfileViewModel()
    
    @State var selectedTab: Tab = .home
    
    enum Tab: String {
        case home
        case workout
        case profile
    }
    
    private var tabItems = [
        TabItem(text: "Feed", icon: "house", tab: .home),
        TabItem(text: "Workout", icon: "figure.walk", tab: .workout),
        TabItem(text: "Profile", icon: "person", tab: .profile)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            Group {
                switch selectedTab {
                case .home:
                    HomeView(homeViewModel: homeViewModel, profileViewModel: profileViewModel)
                        .environmentObject(sessionStore)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                case .workout:
                    WorkoutView()
                        .environmentObject(sessionStore)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                case .profile:
                    ProfileView()
                        .environmentObject(sessionStore)
                        .environmentObject(profileViewModel)
                        .navigationTitle("")
                        .navigationBarHidden(true)
                        .ignoresSafeArea(.keyboard)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Spacer()
                
                ForEach(tabItems) { tabItem in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tabItem.tab
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Image(systemName: tabItem.icon)
                                .symbolVariant(.fill)
                                .font(.body.bold())
                                .frame(width: 44, height: 29)
                            Text(tabItem.text)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(selectedTab == tabItem.tab ? .green : Color(uiColor: .systemGray))
                    }
                    .foregroundStyle(selectedTab == tabItem.tab ? .primary : .secondary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 14)
            .frame(height: 88, alignment: .top)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(
                HStack {
                    if selectedTab == .workout {
                        Spacer()
                    }
                    
                    if selectedTab == .profile {
                        Spacer()
                    }
                    
                    Rectangle()
                        .fill(.green)
                        .frame(width: 40, height: 5)
                        .cornerRadius(3)
                        .frame(width: 88)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    if selectedTab == .home {
                        Spacer()
                    }
                    
                    if selectedTab == .workout {
                        Spacer()
                    }
                }
                .padding(.horizontal, 18)
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
        }
    }
    
    struct TabItem: Identifiable {
        var id = UUID()
        var text: String
        var icon: String
        var tab: Tab
    }
}

struct LoggedUserView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                let sessionStore = SessionStore(forPreviews: true)
                
                LoggedUserView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(sessionStore)
            }
        }
    }
}
