//
//  SettingsFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit
import DBMultiverseComicKit

struct SettingsFeatureNavStack: View {
    @Binding var language: ComicLanguage
    @StateObject var viewModel: SettingsViewModel
    
    let canDismiss: Bool
    
    var body: some View {
        NavStack(title: "Settings") {
            VStack {
                SettingsFormView(viewModel: viewModel, language: language)
                
                Text(NnAppVersionCache.getDeviceVersionDetails(mainBundle: .main))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .onAppear {
                viewModel.loadCachedChapters()
            }
            .animation(.easeInOut, value: viewModel.cachedChapters)
            .withNavBarDismissButton(isActive: canDismiss, dismissType: .xmark)
            .showingAlert("Error", message: "Something went wrong when trying to clear the caches folder", isPresented: $viewModel.showingErrorAlert)
            .showingAlert("Cached Cleared!", message: "All images have been removed from the caches folder", isPresented: $viewModel.showingClearedCacheAlert)
            .navigationDestination(item: $viewModel.route) { route in
                switch route {
                case .cacheList:
                    CacheChapterListView(chapters: viewModel.cachedChapters)
                        .navigationTitle("Cached Chapters")
                case .disclaimer:
                    DisclaimerView()
                case .languageSelection:
                    LanguageSelectionView(selection: language) { updatedLanguage in
                        if updatedLanguage != language {
                            viewModel.clearCache()
                            language = updatedLanguage
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    SettingsFeatureNavStack(language: .constant(.english), viewModel: .init(), canDismiss: true)
}
