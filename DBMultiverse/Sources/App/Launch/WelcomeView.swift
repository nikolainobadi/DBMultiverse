//
//  WelcomeView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/6/25.
//

import SwiftUI
import NnSwiftUIKit
import DBMultiverseComicKit

struct WelcomeView: View {
    @Binding var language: ComicLanguage
    @State private var selectingLanguage = false
    @State private var state: DisclaimerState = .first
    
    let getStarted: () -> Void
    
    var body: some View {
        VStack {
            WelcomeHeaderView()
            
            Spacer()
            
            DisclaimerView(state: $state)
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
            .onlyShow(when: state == .third)
        }
        .animation(.smooth, value: state)
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


// MARK: - Preview
#Preview {
    WelcomeView(language: .constant(.english), getStarted: { })
}
