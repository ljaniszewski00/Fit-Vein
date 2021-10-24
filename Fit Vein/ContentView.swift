//
//  ContentView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @AppStorage("locked") var biometricLock: Bool = true
    @State private var unlocked = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                if self.unlocked || !self.biometricLock {
                    if sessionStore.session != nil {
                        LoggedUserView()
                            .environmentObject(sessionStore)
                            .ignoresSafeArea(.keyboard)
                    } else {
                        SignInView()
                            .environmentObject(sessionStore)
                            .ignoresSafeArea(.keyboard)
                    }
                } else {
                    VStack {
                        Text("Welcome to")
                            .font(.title)
                            .padding(.bottom, screenHeight * 0.02)
                        
                        HStack(spacing: screenWidth * 0.0001) {
                            Text("Fit")
                                .foregroundColor(.green)
                            Text("Vein")
                        }
                        .font(.system(size: screenHeight * 0.1))
                        
                        
                        Spacer()
                        
                        Button(action: {
                            authenticate()
                        }, label: {
                            Image(systemName: "faceid")
                        })
                        .font(.system(size: screenHeight * 0.08))
                        .padding(.bottom, screenHeight * 0.02)
                        
                        Text("Unlock the device first")
                            .foregroundColor(Color(uiColor: UIColor.lightGray))
                        
                        Spacer()
                    }
                    .padding()
                    
                }
            }
            .onAppear {
                if self.biometricLock {
                    authenticate()
                }
                sessionStore.listen()
            }
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Used to take new pictures of the user."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                        self.unlocked = true
                    } else {
                        // there was a problem
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(["iPhone XS MAX", "iPhone 8"], id: \.self) { deviceName in
                ContentView()
                    .preferredColorScheme(colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName(deviceName)
                    .environmentObject(SessionStore())
            }
        }
    }
}
