//
//  iPadMainNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPadMainNavStack<ComicContent: View, SettingsContent: View>: View {
    @State private var showingSettings = false
    @ViewBuilder var comicContent: () -> ComicContent
    @ViewBuilder var settingsContent: () -> SettingsContent
    
    var body: some View {
        ComicNavStack {
            comicContent()
                .withNavBarButton(buttonContent: .image(.system("gearshape"))) {
                    showingSettings = true
                }
                .sheetWithErrorHandling(isPresented: $showingSettings) {
                    settingsContent()
                        .withNavBarDismissButton(dismissType: .xmark)
                }
        }
    }
}