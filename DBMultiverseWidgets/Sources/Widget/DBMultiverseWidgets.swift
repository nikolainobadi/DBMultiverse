//
//  DBMultiverseWidgets.swift
//  DBMultiverseWidgets
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct DBMultiverseWidgets: Widget {
    let kind: String = "DBMultiverseWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DBMultiverseWidgetContentView(entry: entry)
                .containerBackground(LinearGradient.starrySky, for: .widget)
        }
        .configurationDisplayName("DBMultiverse Widget")
        .description("Quickly jump back into the action where you last left off.")
        .supportedFamilies(UIDevice.current.userInterfaceIdiom == .pad ? [.systemMedium] : [.systemSmall])
    }
}


#if DEBUG
// MARK: - Preview
#Preview(as: .systemSmall) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry.makeSample(family: .systemSmall)
}
#endif
