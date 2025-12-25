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
    
    let getStarted: () -> Void
    
    var body: some View {
        VStack {
            header
            Spacer()
            disclaimerSection
            Spacer()
            buttonSection
                .padding()
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Header
private extension WelcomeView {
    var header: some View {
        VStack {
            Text("Welcome to")
                .bold()
            
            HStack {
                Text("Multiverse")
                    .textLinearGradient(.yellowText)
                    
                Text("Reader")
                    .textLinearGradient(.redText)
            }
            .padding(.horizontal)
            .withFont(.title3, autoSizeLineLimit: 1)
            
            Text("for iOS")
                .bold()
        }
    }
    
    @ViewBuilder
    var disclaimerSection: some View {
        if selectingLanguage {
            VStack {
                Text("Choose a language")
                    .padding()
                    .withFont()
                
                LanguagePicker(selection: $language)
            }
        } else {
            DisclaimerView()
        }
    }
    
    @ViewBuilder
    var buttonSection: some View {
        if selectingLanguage {
            Button("Get Started", action: getStarted)
                .padding()
                .withFont()
        } else {
            Button("Select Language") {
                selectingLanguage = true
            }
            .withFont()
        }
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    WelcomeView(language: .constant(.english), getStarted: { })
}
#endif
