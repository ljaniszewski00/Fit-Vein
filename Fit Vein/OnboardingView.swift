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
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            TabView {
                ForEach(0..<3) { number in
                    VStack {
                        Spacer()
                        
                        Text("\(number)")
                            .frame(width: screenWidth * 0.3, height: screenHeight * 0.15)
                            .overlay(Circle()
                                        .stroke())
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Dismiss Onboarding")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        })
                        .background(RoundedRectangle(cornerRadius: 25).frame(width: screenWidth * 0.6, height: screenHeight * 0.07).foregroundColor(.accentColor))
                        .padding(.bottom, screenHeight * 0.12)
                    }
                    .padding()
                    
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
