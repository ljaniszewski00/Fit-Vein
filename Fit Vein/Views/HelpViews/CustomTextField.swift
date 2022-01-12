//
//  CustomTextField.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 11/01/2022.
//

import SwiftUI

struct CustomTextField: View {
    var isSecureField: Bool = false
    var textFieldProperty: String
    var textFieldImageName: String
    var textFieldSignsLimit: Int = 0
    @Binding var text: String
    @Binding var isFocusedParentView: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 15) {
                    Group {
                        if !isSecureField {
                            TextField("", text: $text)
                                .onTapGesture {
                                    withAnimation(.easeIn) {
                                        isFocusedParentView = true
                                        isFocused = true
                                    }
                                }
                                .onSubmit {
                                    withAnimation(.easeOut) {
                                        isFocused = false
                                        isFocusedParentView = false
                                    }
                                }
                        } else {
                            SecureField("", text: $text)
                                .onTapGesture {
                                    withAnimation(.easeIn) {
                                        isFocusedParentView = true
                                        isFocused = true
                                    }
                                }
                                .onSubmit {
                                    withAnimation(.easeOut) {
                                        isFocused = false
                                        isFocusedParentView = false
                                    }
                                }
                        }
                    }
                    .focused($isFocused)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    
                    Image(systemName: textFieldImageName)
                        .foregroundColor(.gray)
                }
                .padding(.top, isFocused ? 15 : 0)
                .background(
                    Text(textFieldProperty)
                        .scaleEffect(text.isEmpty ? (isFocused ? 0.8 : 1) : (isFocused ? 0.8 : 0.8))
                        .offset(x: text.isEmpty ? (isFocused ? -7 : 0) : -7, y: text.isEmpty ? (isFocused ? -20 : 0) : -20)
                        .foregroundColor(isFocused ? .accentColor : .gray)
                    
                    ,alignment: .leading
                )
                .padding(.horizontal)
                
                Rectangle()
                    .fill(isFocused ? Color.accentColor : Color.gray)
                    .opacity(isFocused ? 1 : 0.5)
                    .frame(height: 1)
            }
            .padding(.vertical, isFocused ? 18 : (text.isEmpty ? 12 : 20))
            .background(Color.gray.opacity(0.09))
            .cornerRadius(5)
            
            HStack {
                Spacer()
                
                if textFieldSignsLimit != 0 {
                    Text("\(text.count)/\(textFieldSignsLimit)")
                        .font(.caption)
                        .foregroundColor(text.count > textFieldSignsLimit ? .red : .gray)
                        .padding(.trailing)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State(initialValue: "") var text: String
        @State(initialValue: false) var isFocused: Bool
        
        var body: some View {
            CustomTextField(textFieldProperty: "Username", textFieldImageName: "", textFieldSignsLimit: 15, text: $text, isFocusedParentView: $isFocused)
        }
    }
}
