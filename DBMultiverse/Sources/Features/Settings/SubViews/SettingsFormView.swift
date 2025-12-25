//
//  SettingsFormView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit

struct SettingsFormView: View {
    let language: ComicLanguage
    let cachedChapters: [CachedChapter]
    let clearCache: () -> Void
    let showView: (SettingsRoute) -> Void
    
    var body: some View {
        Form {
            DynamicSection("Cached Data") {
                cachedDataSectionContent
            }
            
            DynamicSection("Language") {
                Text(language.displayName)
                    .padding(5)
                    .textLinearGradient(.redText)
                    .tappable(withChevron: true) {
                        showView(.languageSelection)
                    }
                    .withFont()
            }
            
            DynamicSection("Web Comic Links") {
                ForEach(SettingsLinkItem.allCases, id: \.name) { link in
                    linkRow(link)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}


// MARK: - Subviews
private extension SettingsFormView {
    @ViewBuilder
    var cachedDataSectionContent: some View {
        if cachedChapters.isEmpty {
            Text("No cached data")
        } else {
            VStack {
                Text("View Cached Chapters")
                    .foregroundColor(.blue)
                    .withFont()
                    .tappable(withChevron: true) {
                        showView(.cacheList)
                    }
                
                Divider()
                
                HapticButton("Clear All Cached Data", action: clearCache)
                    .padding()
                    .tint(.red)
                    .buttonStyle(.bordered)
                    .withFont(textColor: .red)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    func linkRow(_ link: SettingsLinkItem) -> some View {
        if let url = URLFactory.makeURL(language: language, pathComponent: link.pathComponent) {
            Link(link.name, destination: url)
                .padding(.vertical, 10)
                .textLinearGradient(.lightStarrySky)
                .asRowItem(withChevron: true)
                .withFont()
        }
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    SettingsFormView(language: .english, cachedChapters: [], clearCache: { }, showView: { _ in })
        .withPreviewModifiers()
}
#endif
