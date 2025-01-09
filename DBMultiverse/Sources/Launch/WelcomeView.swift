//
//  WelcomeView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/6/25.
//

import SwiftUI
import NnSwiftUIKit

struct WelcomeView: View {
    @State private var didAgree = false
    
    let getStarted: () -> Void
    
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
            
            Spacer()
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
            
            Spacer()
            
            VStack {
                Toggle("I understand", isOn: $didAgree)
                    .toggleStyle(CheckboxToggleStyle())
                
                Button("Get Started", action: getStarted)
                    .padding()
                    .withFont()
                    .buttonStyle(.borderedProminent)
                    .onlyShow(when: didAgree)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Preview
#Preview {
    WelcomeView(getStarted: { })
}


// MARK: - Helpers
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    
                configuration.label
            }
            .bold()
            .textLinearGradient(.yellowText)
            .withFont()
        })
    }
}
