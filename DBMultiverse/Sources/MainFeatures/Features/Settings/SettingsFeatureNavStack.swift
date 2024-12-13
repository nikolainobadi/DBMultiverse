//
//  SettingsFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct SettingsFeatureNavStack: View {
    @State private var showingCacheList = false
    @StateObject private var cacheManager = CacheManager()
    
    var body: some View {
        NavStack(title: "Settings") {
            Form {
                Section("Cached Data") {
                    VStack {
                        Text("View Cached Chapters")
                            .foregroundColor(.blue)
                            .tappable(withChevron: true) {
                                showingCacheList = true
                            }
                        
                        Divider()
                        
                        HapticButton("Clear All Cached Data", action: cacheManager.clearCache)
                            .padding()
                            .tint(.red)
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                    }
                    .showingConditionalView(when: cacheManager.cachedChapters.isEmpty) {
                        Text("No cached data")
                    }
                }
                
                Section("DBMultiverse Web Comic Links") {
                    Link("Authors", destination: .init(string: .makeFullURLString(suffix: "/en/the-authors.html"))!)
                    Link("Universe Help", destination: .init(string: .makeFullURLString(suffix: "/en/listing.html"))!)
                    Link("Tournament Help", destination: .init(string: .makeFullURLString(suffix: "/en/tournament.html"))!)
                }
            }
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
