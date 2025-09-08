//
//  iPhoneMainTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPhoneMainTabView<ComicTab: View, SettingsTab: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder var comicContent: () -> ComicTab
    @ViewBuilder var settingsTab: () -> SettingsTab
    
    var body: some View {
        TabView {
            ComicNavStack(path: $path, content: comicContent)
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
