//
//  iPhoneMainTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPhoneMainTabView<SettingsTab: View>: View {
    let settingsTab: () -> SettingsTab
    
    init(@ViewBuilder settingsTab: @escaping () -> SettingsTab) {
        self.settingsTab = settingsTab
    }
    
    var body: some View {
        TabView {
            ComicNavStack {
                Text("Chapter List")
            }
            .tabItem {
                Label("Comic", systemImage: "book")
            }
            
            settingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}


// MARK: - Preview
#Preview {
    iPhoneMainTabView {
        Text("Settings")
    }
}
