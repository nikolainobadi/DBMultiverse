//
//  SettingsDisclaimerView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import DBMultiverseComicKit

struct SettingsDisclaimerView: View {
    @State private var state: DisclaimerState = .first
    
    var body: some View {
        VStack {
            ComicNavBar()
            DisclaimerView(state: $state)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsDisclaimerView()
}
