//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI
import NnSwiftUIKit
import NnSwiftDataKit

struct DBMultiverseApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .syncWidgetData()
                .withNnLoadingView()
                .withNnErrorHandling()
                .preferredColorScheme(.dark)
        }
        .initializeSwiftDataModelContainer(schema: .init([SwiftDataChapter.self]))
    }
}
