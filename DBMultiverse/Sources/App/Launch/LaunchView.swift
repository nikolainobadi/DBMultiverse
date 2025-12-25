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
        if isInitialLogin {
            WelcomeView(language: $language) {
                isInitialLogin = false
            }
        } else {
            MainFeaturesView(language: $language, viewModel: .customInit())
        }
    }
}


// MARK: - Extension Dependencies
private extension MainFeaturesViewModel {
    static func customInit() -> MainFeaturesViewModel {
        return .init(loader: ChapterLoaderAdapter())
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    LaunchView()
        .withPreviewModifiers()
}
#endif
