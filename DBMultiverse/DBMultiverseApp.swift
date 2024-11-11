//
//  DBMultiverseApp.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/9/24.
//

import SwiftUI

@main
struct DBMultiverseApp: App {
    @AppStorage("lastReadPage") private var lastReadPage: Int = 0
    
    var body: some Scene {
        WindowGroup {
            ComicFeatureView(lastReadPage: $lastReadPage, viewModel: .init(currentPageNumber: lastReadPage))
                .preferredColorScheme(.dark)
        }
    }
}
