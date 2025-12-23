//
//  Provider.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import UIKit
import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct Provider: TimelineProvider {
    private let coverImageManager = CoverImageManager()
    
    func placeholder(in context: Context) -> ComicImageEntry {
        .makeSample(family: context.family)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ComicImageEntry) -> Void) {
        completion(loadEntry(for: context.family) ?? makePlaceholderEntry(for: context.family))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComicImageEntry>) -> Void) {
        let entry = loadEntry(for: context.family) ?? makePlaceholderEntry(for: context.family)
        completion(.init(entries: [entry], policy: .never))
    }
}


// MARK: - private Methods
private extension Provider {
    func loadEntry(for family: WidgetFamily) -> ComicImageEntry? {
        guard let chapterData = coverImageManager.loadCurrentChapterData() else {
            return nil
        }
        
        let deepLink = URL(string: "dbmultiverse://chapter/\(chapterData.number)") ?? .sampleURL
        
        return .init(
            date: .now,
            chapter: chapterData.number,
            name: chapterData.name,
            progress: chapterData.progress,
            image: makeImage(path: chapterData.coverImagePath),
            family: family,
            deepLink: deepLink
        )
    }
    
    func makePlaceholderEntry(for family: WidgetFamily) -> ComicImageEntry {
        return .init(date: .now, chapter: 0, name: "", progress: 0, image: nil, family: family, deepLink: .sampleURL)
    }
    
    func makeImage(path: String?) -> Image? {
        guard let path, let uiImage = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        return .init(uiImage: uiImage)
    }
}
