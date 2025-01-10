//
//  DisclaimerView.swift
//  
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI

public struct DisclaimerView: View {
    @Binding var state: DisclaimerState
    
    let feedbackEmail = "iosdbmultiverse@gmail.com"
    
    public init(state: Binding<DisclaimerState>) {
        self._state = state
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading) {
                Text(state.details)
                    .withFont(.caption2)
                
                Text(feedbackEmail)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .onlyShow(when: state == .third)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer()
            
            if let nextState = state.nextState {
                Button(action: { state = nextState }) {
                    Text("Next")
                        .withFont()
                        .frame(maxWidth: getWidthPercent(60))
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
        }
        .animation(.easeInOut, value: state)
    }
}


// MARK: - Dependencies
public enum DisclaimerState: Int {
    case first, second, third
    
    var nextState: DisclaimerState? {
        return .init(rawValue: rawValue + 1)
    }
    
    var details: String {
        switch self {
        case .first:
            return "This is an unofficial fan-made app."
                .skipLine("While I did receive permission from Salagir to distribute this app for free, it was NOT developed by the DBMultiverse team.")
                .skipLine("I made this app as a way to make the webcomic easier to read on iOS.")
        case .second:
            return "This app is a non-commercial project and is provided for free. No revenue, advertising, or other monetization methods are associated with this app."
                .skipLine("All rights to the Dragon Ball franchise belong to Toei Animation, Shueisha, and their respective owners.")
                .skipLine("The DBMultiverse webcomic and all associated content are the property of Salagir and the DBMultiverse team.")
                .skipLine("Users are responsible for ensuring their use of this app complies with copyright laws and terms of use for the content they access.")
        case .third:
            return "The developer of this app assumes no responsibility for misuse or any consequences resulting from the use of this app. This app is provided 'as is' without warranty of any kind."
                .skipLine("Please support the DBMultiverse webcomic by visiting their official website: https://www.dragonball-multiverse.com")
                .skipLine("If you have any questions and/or concerns, please send them to:")
        }
    }
}

