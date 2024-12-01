//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI
import NnSwiftUIKit

@main
struct DBMultiverseApp: App {
    var body: some Scene {
        WindowGroup {
            ChapterListFeatureView()
                .preferredColorScheme(.dark)
                .withNnLoadingView()
                .withNnErrorHandling()
        }
    }
}
