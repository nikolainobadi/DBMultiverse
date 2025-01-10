//
//  LaunchView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/6/25.
//

import SwiftUI
import NnSwiftUIKit

struct LaunchView: View {
    @AppStorage("isInitialLogin") private var isInitialLogin = true
    @AppStorage("selectedLanguage") private var language: ComicLanguage = .english
    
    var body: some View {
        MainFeaturesView(viewModel: .init(loader: ChapterLoaderAdapter()), language: $language)
            .showingConditionalView(when: isInitialLogin) {
                WelcomeView(language: $language) {
                    isInitialLogin = false
                }
            }
    }
}


// MARK: - Preview
#Preview {
    LaunchView()
        .withPreviewModifiers()
}
