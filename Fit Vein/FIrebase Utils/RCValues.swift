//
//  RCValues.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 03/01/2022.
//

//import Foundation
//import SwiftUI
//import Firebase
//
//var appPrimaryColor: Color {
//    RCValues.sharedInstance.color(forKey: .appPrimaryColor)
//}
//
//class RCValues {
//    enum ValueKey: String {
//        case appPrimaryColor
//    }
//    
//    static let sharedInstance = RCValues()
//    
//    var loadingDoneCallback: (() -> Void)?
//    var fetchComplete = false
//
//    private init() {
//        loadDefaultValues()
//        fetchCloudValues()
//    }
//
//    func loadDefaultValues() {
//        let appDefaults: [String: Any?] = [
//            ValueKey.appPrimaryColor.rawValue : "#00D100"
//        ]
//        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
//    }
//    
//    func activateDebugMode() {
//        let settings = RemoteConfigSettings()
//        // WARNING: Don't actually do this in production!
//        settings.minimumFetchInterval = 0
//        RemoteConfig.remoteConfig().configSettings = settings
//    }
//    
//    func fetchCloudValues() {
//        activateDebugMode()
//
//        RemoteConfig.remoteConfig().fetch { [weak self] _, error in
//            if let error = error {
//                print("Error fetching remote values: \(error)")
//                return
//                
//            }
//
//            RemoteConfig.remoteConfig().activate { _, _ in
//                print("Retrieved values from the cloud!")
//            }
//            
//            self?.fetchComplete = true
//            
//            DispatchQueue.main.async {
//                self?.loadingDoneCallback?()
//            }
//        }
//    }
//    
//    func color(forKey key: ValueKey) -> Color {
//        let colorAsHexString = RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? "#00D100"
//        let convertedColor = Color(hex: colorAsHexString)
//        if self.fetchComplete {
//            return convertedColor
//        } else {
//            return Color(.red)
//        }
//        
//    }
//    
//    func bool(forKey key: ValueKey) -> Bool {
//      RemoteConfig.remoteConfig()[key.rawValue].boolValue
//    }
//
//    func string(forKey key: ValueKey) -> String {
//      RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
//    }
//
//    func double(forKey key: ValueKey) -> Double {
//      RemoteConfig.remoteConfig()[key.rawValue].numberValue.doubleValue
//    }
//}
