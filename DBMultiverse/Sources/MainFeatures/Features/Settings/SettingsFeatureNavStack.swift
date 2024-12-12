//
//  SettingsFeatureNavStack.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct SettingsFeatureNavStack: View {
    var body: some View {
        NavStack(title: "Settings") {
            Form {
                Section("Cached Data") {
                    NavigationLink(destination: CachedChaptersView()) {
                        Text("View Cached Chapters")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: clearCache) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear All Cached Data")
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Cache Clearing Logic
    private func clearCache() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in contents {
                try FileManager.default.removeItem(at: file)
            }
            print("Cache cleared successfully.")
        } catch {
            print("Failed to clear cache: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsFeatureNavStack()
}


final class CacheManager: ObservableObject {
    @Published var cachedChapters: [CachedChapter] = []

    // Load all cached chapters
    func loadCachedChapters() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let chaptersDirectory = cacheDirectory.appendingPathComponent("Chapters")

        var chapters: [CachedChapter] = []
        do {
            let chapterFolders = try FileManager.default.contentsOfDirectory(at: chaptersDirectory, includingPropertiesForKeys: nil)
            
            for folder in chapterFolders {
                let chapterNumber = folder.lastPathComponent.replacingOccurrences(of: "Chapter_", with: "")
                let images = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
                let imageCount = images.filter { $0.pathExtension.lowercased() == "jpg" }.count

                chapters.append(CachedChapter(number: chapterNumber, imageCount: imageCount))
            }
        } catch {
            print("Failed to load cached chapters: \(error.localizedDescription)")
        }
        cachedChapters = chapters
    }
}

struct CachedChapter: Identifiable {
    let id = UUID()
    let number: String
    let imageCount: Int
}

struct CachedChaptersView: View {
    @StateObject private var cacheManager = CacheManager()

    var body: some View {
        List(cacheManager.cachedChapters) { chapter in
            HStack {
                Text("Chapter \(chapter.number)")
                Spacer()
                Text("\(chapter.imageCount) Images")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            cacheManager.loadCachedChapters()
        }
        .navigationTitle("Cached Chapters")
    }
}

// MARK: - Preview
#Preview {
    CachedChaptersView()
}
