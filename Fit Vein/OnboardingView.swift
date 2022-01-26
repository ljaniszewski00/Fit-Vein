//
//  OnboardingView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 24/10/2021.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var imagesNames: [String] = ["", "HomeTabView", "PostCommentsView", "SearchFriendsView", "WorkoutsView", "AddWorkoutView", "WorkoutTimerView", "FinishedWorkoutView", "ProfileView", "HealthTabView", "WorkoutsTabView", "WorkoutsTabViewList", "SettingsView", "MedalView"]
    
    private var titles: [String] = [String(localized: "Onboarding_welcome_title"), String(localized: "Onboarding_home_tab_view_title"), String(localized: "Onboarding_post_comments_title"), String(localized: "Onboarding_search_friends_view_title"), String(localized: "Onboarding_workouts_view_title"), String(localized: "Onboarding_add_workout_view_title"), String(localized: "Onboarding_workout_timer_view_title"), String(localized: "Onboarding_finished_workout_view_title"), String(localized: "Onboarding_profile_view_title"), String(localized: "Onboarding_health_tab_view_title"), String(localized: "Onboarding_workouts_tab_view_title"), String(localized: "Onboarding_workouts_tab_view_list_title"), String(localized: "Onboarding_settings_view_title"), String(localized: "Onboarding_medal_view_title")]
    
    private var descriptions: [String] = [String(localized: "Onboarding_welcome_description"), String(localized: "Onboarding_home_tab_view_description"), String(localized: "Onboarding_post_comments_description"), String(localized: "Onboarding_search_friends_view_description"), String(localized: "Onboarding_workouts_view_description"), String(localized: "Onboarding_add_workout_view_description"), String(localized: "Onboarding_workout_timer_view_description"), String(localized: "Onboarding_finished_workout_view_description"), String(localized: "Onboarding_profile_view_description"), String(localized: "Onboarding_health_tab_view_description"), String(localized: "Onboarding_workouts_tab_view_description"), String(localized: "Onboarding_workouts_tab_view_list_description"), String(localized: "Onboarding_settings_view_description"), String(localized: "Onboarding_medal_view_description")]
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                ZStack() {
                    TabView {
                        ForEach(0..<imagesNames.count) { number in
                            VStack {
                                Spacer()
                                
                                if number == 0 {
                                    LottieView(name: "hello", loopMode: .loop, contentMode: .scaleAspectFill)
                                        .frame(width: screenWidth * 0.7, height: screenHeight * 0.35)
                                } else {
                                    Image(uiImage: UIImage(named: imagesNames[number])!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenWidth * 0.5, height: screenHeight * 0.5)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .center) {
                                    Text(titles[number])
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(.bottom, screenHeight * 0.025)
                                    
                                    Text(descriptions[number])
                                        .font(.system(size: number == 0 ? screenHeight * 0.03 : screenHeight * 0.02))
                                        .padding(.bottom, screenHeight * 0.025)
                                    
                                    Spacer()
                                }
                                .padding()
                                .frame(width: screenWidth, height: screenHeight * 0.3)
                                .background(Color.accentColor)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
                HStack {
                    Button(action: {
                        withAnimation {
                            dismiss()
                        }
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color(uiColor: UIColor(red: 180, green: 255, blue: 180)))
                            
                            HStack {
                                Text(String(localized: "Onboarding_get_started_button"))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(uiColor: UIColor(red: 100, green: 215, blue: 100)))
                            }
                            .padding(.horizontal)
                            .frame(height: screenHeight * 0.05)
                        }
                        .frame(width: screenWidth * 0.4, height: screenHeight * 0.06)
                    })
                }
                .padding()
                .frame(width: screenWidth)
                .background(Color(uiColor: .systemGray6))
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
