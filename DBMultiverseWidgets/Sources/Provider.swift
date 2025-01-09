//
//  Provider.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ComicImageEntry {
        return .makeSample(family: context.family)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ComicImageEntry) -> Void) {
        completion(.makeSample(family: context.family))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComicImageEntry>) -> Void) {
        guard let chapterData = CoverImageCache.shared.loadCurrentChapterData() else {
            completion(.init(entries: [.init(date: .now, chapter: 0, name: "", progress: 0, image: nil, family: context.family)], policy: .atEnd))
            return
        }
        
        let progress = chapterData.progress
        let image = makeImage(path: chapterData.coverImagePath)
        let entry = ComicImageEntry(date: .now, chapter: chapterData.number, name: chapterData.name, progress: progress, image: image, family: context.family)
        
        completion(.init(entries: [entry], policy: .atEnd))
    }
}


// MARK: - private Methods
private extension Provider {
    func makeImage(path: String?) -> Image? {
        guard let path, let uiImage = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        return .init(uiImage: uiImage)
    }
}
