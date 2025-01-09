//
//  ComicImageEntry.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

struct ComicImageEntry: TimelineEntry {
    let date: Date
    let chapter: Int
    let name: String
    let progress: Int
    let image: Image?
    let family: WidgetFamily
    let deepLink: URL
}

extension ComicImageEntry {
    static func makeSample(family: WidgetFamily) -> ComicImageEntry {
        return .init(date: .now, chapter: 1, name: "A Really Strange Tournament!", progress: 0, image: .init("sampleCoverImage"), family: family, deepLink: .sampleURL)
    }
}

extension URL {
    static var sampleURL: URL {
        return .init(string: "dbmultiverse://chapter/1")!
    }
}
