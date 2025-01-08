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
    
//    let loader: ChapterLoader
    
    var body: some View {
        MainFeaturesView(viewModel: .init(loader: ChapterLoaderAdapter()))
            .showingConditionalView(when: isInitialLogin) {
                WelcomeView {
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
