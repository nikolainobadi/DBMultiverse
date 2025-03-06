//
//  DisclaimerView.swift
//  
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import NnSwiftUIKit

public struct DisclaimerView: View {
    let feedbackEmail = "iosdbmultiverse@gmail.com"
    
    public init() {
        
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            Text(LocalizedStringKey(.disclaimerDetails))
                .withFont(.caption2)
                .padding()
                .background(.thinMaterial)
                .clipShape(.rect(cornerRadius: 10))
            
            Spacer()
        }
    }
}


// MARK: - Dependencies
extension String {
    static var disclaimerDetails: String {
        return "This is an **unofficial fan-made app** and is not affiliated with, endorsed, or sponsored by Toei Animation, Shueisha, or any official rights holders."
            .skipLine("Permission was granted by Salagir to distribute this app for free, but it was **not developed by the DB Multiverse team**.")
            .skipLine("This app is a **non-commercial project**, provided free of charge with no ads, monetization, or revenue generation.")
            .skipLine("All rights to the original *DB Multiverse* webcomic belong to Salagir and the *DB Multiverse* team.")
            .skipLine("For any questions or concerns, please contact:")
            .skipLine("**iosdbmultiverse@gmail.com**")
    }
}
