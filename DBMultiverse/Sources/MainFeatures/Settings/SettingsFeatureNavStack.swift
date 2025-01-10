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
    @State private var showingCacheList = false
    @StateObject var viewModel: SettingsViewModel
    
    let canDismiss: Bool
    
    var body: some View {
        NavStack(title: "Settings") {
            VStack {
                Form {
                    DynamicSection("Cached Data") {
                        VStack {
                            Text("View Cached Chapters")
                                .foregroundColor(.blue)
                                .withFont()
                                .tappable(withChevron: true) {
                                    showingCacheList = true
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
                    
                    DynamicSection("Web Comic Links") {
                        ForEach(SettingsLinkItem.allCases, id: \.name) { link in
                            if let url = viewModel.makeURL(for: link, language: language) {
                                Link(link.name, destination: url)
                                    .padding(.vertical, 10)
                                    .withFont(textColor: .blue)
                                    .asRowItem(withChevron: true)
                            }
                        }
                    }
                }
                .frame(maxHeight: getHeightPercent(45))
                .scrollContentBackground(.hidden)
                
                VStack(alignment: .center) {
                    Text("This is an unofficial iOS app.\n")
                    Text("Please send any questions or concerns to:\n")
                    Text(FEEDBACK_EMAIL)
                        .foregroundStyle(.blue)
                }
                .multilineTextAlignment(.center)
                .padding([.bottom, .horizontal])
                .withFont()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay(alignment: .bottom) {
                Text(NnAppVersionCache.getDeviceVersionDetails(mainBundle: .main))
                    .font(.caption)
                    .padding()
            }
            .onAppear {
                viewModel.loadCachedChapters()
            }
            .animation(.easeInOut, value: viewModel.cachedChapters)
            .withNavBarDismissButton(isActive: canDismiss, dismissType: .xmark)
            .showingAlert("Error", message: "Something went wrong when trying to clear the caches folder", isPresented: $viewModel.showingErrorAlert)
            .showingAlert("Cached Cleared!", message: "All images have been removed from the caches folder", isPresented: $viewModel.showingClearedCacheAlert)
            .navigationDestination(isPresented: $showingCacheList) {
                List(viewModel.cachedChapters, id: \.number) { chapter in
                    HStack {
                        Text("Chapter \(chapter.number)")
                        Spacer()
                        Text("\(chapter.imageCount) Images")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Cached Chapters")
            }
        }
    }
}


// MARK: - Preview
#Preview {
    SettingsFeatureNavStack(language: .constant(.english), viewModel: .init(), canDismiss: true)
}
