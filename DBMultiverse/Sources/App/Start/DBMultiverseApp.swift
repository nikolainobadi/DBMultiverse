//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI
import NnSwiftUIKit

struct DBMultiverseApp: App {
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .syncWidgetData()
                .withNnLoadingView()
                .withNnErrorHandling()
                .preferredColorScheme(.dark)
                .initializeSwiftDataModelConatainer()
        }
    }
}
