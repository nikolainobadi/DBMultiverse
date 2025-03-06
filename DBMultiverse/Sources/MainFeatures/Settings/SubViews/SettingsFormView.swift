//
//  SettingsFormView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit

struct SettingsFormView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    let language: ComicLanguage
    
    var body: some View {
        Form {
            DynamicSection("Cached Data") {
                VStack {
                    Text("View Cached Chapters")
                        .foregroundColor(.blue)
                        .withFont()
                        .tappable(withChevron: true) {
                            viewModel.showView(.cacheList)
                        }
                    
                    Divider()
                    
                    HapticButton("Clear All Cached Data", action: viewModel.clearCache)
                        .padding()
                        .tint(.red)
                        .buttonStyle(.bordered)
                        .withFont(textColor: .red)
                        .frame(maxWidth: .infinity)
                }
                .showingConditionalView(when: viewModel.cachedChapters.isEmpty) {
                    Text("No cached data")
                }
            }
            
            DynamicSection("Language") {
                Text(language.displayName)
                    .padding(5)
                    .textLinearGradient(.redText)
                    .tappable(withChevron: true) {
                        viewModel.showView(.languageSelection)
                    }
                    .withFont()
            }
            
            DynamicSection("Web Comic Links") {
                ForEach(SettingsLinkItem.allCases, id: \.name) { link in
                    if let url = viewModel.makeURL(for: link, language: language) {
                        Link(link.name, destination: url)
                            .padding(.vertical, 10)
                            .textLinearGradient(.lightStarrySky)
                            .asRowItem(withChevron: true)
                            .withFont()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}


// MARK: - Preview
#Preview {
    SettingsFormView(viewModel: .init(), language: .english)
}
