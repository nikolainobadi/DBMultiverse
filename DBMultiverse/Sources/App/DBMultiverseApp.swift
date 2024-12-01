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
    @StateObject private var sharedDataENV: SharedDataENV = .init()
    
    var body: some Scene {
        WindowGroup {
            MainFeaturesTabView(viewModel: .init(env: sharedDataENV))
                .preferredColorScheme(.dark)
                .withNnLoadingView()
                .withNnErrorHandling()
                .environmentObject(sharedDataENV)
        }
    }
}
