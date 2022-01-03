//
//  Fit_VeinApp.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI
import Firebase

@main
struct Fit_VeinApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            let sessionStore = SessionStore(forPreviews: false)
            PreLaunchView()
                .environmentObject(sessionStore)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Installations.installations().authTokenForcingRefresh(true, completion: { (result, error) in
          if let error = error {
            print("Error fetching token: \(error)")
            return
          }
          guard let result = result else { return }
          print("Installation auth token: \(result.authToken)")
        })
        
        _ = RCValues.sharedInstance
        
        return true
    }
}

extension UIApplication {
    struct Constants {
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
    }
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: Constants.CFBundleShortVersionString) as! String
    }
  
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
  
    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
      
        return version == build ? "\(version)" : "\(version) (\(build))"
    }
}

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension StringProtocol {
    var letters: String {
        return String(compactMap {
            guard let unicodeScalar = $0.unicodeScalars.first else { return nil }
            return CharacterSet.letters.contains(unicodeScalar) ? $0 : nil
        })
    }
}

extension StringProtocol {
    public func removeCharactersFromString(string: String, character: String, before: Bool, upToCharacter: String?) -> String {
        if let startingCharacterindex = string.range(of: character)?.lowerBound {
            var substring = ""
            
            if before {
                substring = String(string.prefix(upTo: startingCharacterindex))
            } else {
                if upToCharacter != nil {
                    if let endingCharacterIndex = string.range(of: upToCharacter!)?.lowerBound {
                        let lastCharacterIndex = string.endIndex
                        substring = String(string[..<startingCharacterindex]) + String(string[endingCharacterIndex..<lastCharacterIndex])
                    } else {
                        substring = String(string[..<startingCharacterindex])
                    }
                }
            }
            return substring
        } else {
            return ""
        }
    }
}

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
