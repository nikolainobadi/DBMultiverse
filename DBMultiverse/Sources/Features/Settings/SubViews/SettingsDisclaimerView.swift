//
//  SettingsDisclaimerView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import DBMultiverseComicKit

struct SettingsDisclaimerView: View {
    var body: some View {
        VStack {
            ComicNavBar()
            DisclaimerView()
        }
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    SettingsDisclaimerView()
}
#endif
