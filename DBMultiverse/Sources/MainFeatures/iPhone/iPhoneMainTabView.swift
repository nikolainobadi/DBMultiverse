//
//  iPhoneMainTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPhoneMainTabView<ComicTab: View, SettingsTab: View>: View {
    @ViewBuilder var comicContent: () -> ComicTab
    @ViewBuilder var settingsTab: () -> SettingsTab
    
    var body: some View {
        TabView {
            ComicNavStack(content: comicContent)
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
