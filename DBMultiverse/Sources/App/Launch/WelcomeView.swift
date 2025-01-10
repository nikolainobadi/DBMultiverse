//
//  WelcomeView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/6/25.
//

import SwiftUI
import NnSwiftUIKit

struct WelcomeView: View {
    @Binding var language: ComicLanguage
    @State private var selectingLanguage = false
    
    let getStarted: () -> Void
    
    var body: some View {
        VStack {
            WelcomeHeaderView()
            
            Spacer()
            
            DisclaimerView()
                .showingConditionalView(when: selectingLanguage) {
                    VStack {
                        Text("Choose a language")
                            .padding()
                            .withFont()
                        
                        LanguagePicker(selection: $language)
                    }
                }
            
            Spacer()
            
            VStack {
                Button("Select Language") {
                    selectingLanguage = true
                }
                .withFont()
                .showingConditionalView(when: selectingLanguage) {
                    Button("Get Started", action: getStarted)
                        .padding()
                        .withFont()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Header
fileprivate struct WelcomeHeaderView: View {
    var body: some View {
        VStack {
            Text("Welcome to")
                .bold()
            
            HStack {
                Text("Dragon Ball")
                    .textLinearGradient(.yellowText)
                    
                Text("Multiverse")
                    .textLinearGradient(.redText)
            }
            .padding(.horizontal)
            .withFont(.title3, autoSizeLineLimit: 1)
            
            Text("for iOS")
                .bold()
        }
    }
}


// MARK: - Disclaimer
fileprivate struct DisclaimerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This is an unofficial fan-made app.\n")
            
            Text("While I did receive permission from Salagir to distribute this app for free, it was NOT developed by the DBMultiverse team.\n")
            
            Text("I made this app as a way to make the web comic easier to read on iOS.\n")
            
            Text("As such, please direct any questions and/or concerns to:\n")
            
            Text(FEEDBACK_EMAIL)
                .bold()
                .frame(maxWidth: .infinity)
                
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .withFont(.caption)
        .padding()
    }
}


// MARK: - Preview
#Preview {
    WelcomeView(language: .constant(.english), getStarted: { })
}
