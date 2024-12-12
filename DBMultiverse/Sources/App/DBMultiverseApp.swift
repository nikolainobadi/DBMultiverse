//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

@main
struct DBMultiverseApp: App {
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    var body: some Scene {
        WindowGroup {
            MainFeaturesTabView()
                .withNnLoadingView()
                .withNnErrorHandling()
                .preferredColorScheme(.dark)
                .modelContainer(for: SwiftDataChapter.self)
        }
    }
}
