//
//  MedalsViewModel.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 29/01/2022.
//

import Foundation

@MainActor
class MedalsViewModel: ObservableObject {
    var sessionStore = SessionStore(forPreviews: false)
    private let firestoreManager = FirestoreManager()
    
    private(set) var allMedalsDescriptions: [String: String] = [
        "medalFirstLevel": String(localized: "ProfileView_medal_first_level"),
        "medalSecondLevel": String(localized: "ProfileView_medal_second_level"),
        "medalThirdLevel": String(localized: "ProfileView_medal_third_level"),
        "medalFirstPost": String(localized: "ProfileView_medal_first_post"),
        "medalFirstComment":  String(localized: "ProfileView_medal_first_comment"),
        "medalFirstLike": String(localized: "ProfileView_medal_first_like"),
        "medalFirstWorkout": String(localized: "ProfileView_medal_first_workout"),
        "medalFirstOwnWorkout": String(localized: "ProfileView_medal_first_own_workout")]
    
    @Published var allUsersMedals: [String] = []
    
    init() {
        fetchUsersMedals()
    }
    
    func fetchUsersMedals() {
        if let currentUser = sessionStore.currentUser {
            firestoreManager.fetchDataForMedalsViewModel(userID: currentUser.uid) { medals in
                self.allUsersMedals = medals.sorted(by: <)
            }
        }
    }
    
    func giveUserMedal(medalName: String) {
        if let currentUser = sessionStore.currentUser {
            if !allUsersMedals.contains(medalName) {
                firestoreManager.giveUserMedal(userID: currentUser.uid, medalName: medalName) { success in }
            }
        }
    }
}
