//
//  Provider.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ComicImageEntry {
        ComicImageEntry(date: Date(), image: .init("sampleCoverImage"), family: context.family)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ComicImageEntry) -> Void) {
        completion(ComicImageEntry(date: Date(), image: .init("sampleCoverImage"), family: context.family))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComicImageEntry>) -> Void) {
        let imagePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("latestChapterImage.jpg").path
        let image = makeImage(path: imagePath)
        let entry = ComicImageEntry(date: .now, image: image, family: context.family)
        
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
