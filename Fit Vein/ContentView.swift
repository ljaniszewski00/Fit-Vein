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
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            NavigationView {
                if sessionStore.session != nil {
                    VStack {
                        Text("You are signed in!")
                        Button(action: {
                            withAnimation {
                                sessionStore.signOut()
                            }
                        }, label: {
                            Text("Sign Out")
                        })
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.green))
                        .padding()
                        .padding(.top, screenHeight * 0.05)
                    }
                } else {
                    SignInView()
                        .environmentObject(sessionStore)
                        .ignoresSafeArea(.keyboard)
                }
            }
            .onAppear {
                sessionStore.listen()
            }
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
