//
//  ContentView.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    
    var body: some View {
        NavigationView {
            if sessionStore.isSignedIn {
                Text("You are signed in!")
            } else {
                SignInView()
                    .environmentObject(sessionStore)
            }
        }
        .onAppear {
            sessionStore.signedIn = sessionStore.isSignedIn
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
            }
        }
    }
}
