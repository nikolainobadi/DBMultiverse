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
        MainFeaturesView(language: $language, viewModel: .customInit())
            .showingConditionalView(when: isInitialLogin) {
                WelcomeView(language: $language) {
                    isInitialLogin = false
                }
            }
    }
}


private extension MainFeaturesViewModel {
    static func customInit() -> MainFeaturesViewModel {
        return .init(loader: ChapterLoaderAdapter(), widgetTimelineReloader: WidgetTimelineManager())
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    LaunchView()
        .withPreviewModifiers()
}
#endif
