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
    @State private var showingCacheList = false
    @StateObject private var cacheManager = SettingsViewModel()
    
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
                            
                            HapticButton("Clear All Cached Data", action: cacheManager.clearCache)
                                .padding()
                                .tint(.red)
                                .buttonStyle(.bordered)
                                .withFont(textColor: .red)
                                .frame(maxWidth: .infinity)
                        }
                        .showingConditionalView(when: cacheManager.cachedChapters.isEmpty) {
                            Text("No cached data")
                        }
                    }
                    
                    DynamicSection("Web Comic Links") {
                        ForEach(SettingsLinkItem.allCases, id: \.name) { link in
                            Link(link.name, destination: .init(string: .makeFullURLString(suffix: link.linkSuffix))!)
                                .padding(.vertical, 10)
                                .withFont(textColor: .blue)
                                .asRowItem(withChevron: true)
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
            }
            .onAppear {
                cacheManager.loadCachedChapters()
            }
            .animation(.easeInOut, value: cacheManager.cachedChapters)
            .showingAlert("Error", message: "Something went wrong when trying to clear the caches folder", isPresented: $cacheManager.showingErrorAlert)
            .showingAlert("Cached Cleared!", message: "All images have been removed from the caches folder", isPresented: $cacheManager.showingClearedCacheAlert)
            .navigationDestination(isPresented: $showingCacheList) {
                List(cacheManager.cachedChapters, id: \.number) { chapter in
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
    SettingsFeatureNavStack()
}