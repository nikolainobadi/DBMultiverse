//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI

@main
struct DBMultiverseApp: App {
    var body: some Scene {
        WindowGroup {
            ChapterListFeatureView()
                .preferredColorScheme(.dark)
        }
    }
}
