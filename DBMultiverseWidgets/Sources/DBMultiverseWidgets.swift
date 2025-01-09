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


// MARK: - ContentView
fileprivate struct DBMultiverseWidgetContentView: View {
    let entry: ComicImageEntry
    
    var body: some View {
        if entry.family == .systemSmall {
            SmallWidgetView(entry: entry)
        } else {
            MediumWidgetView(entry: entry)
        }
    }
}



// MARK: - Preview
#Preview(as: .systemSmall) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry.makeSample(family: .systemSmall)
}
//#Preview(as: .systemMedium) {
//    DBMultiverseWidgets()
//} timeline: {
//    ComicImageEntry.makeSample(family: .systemMedium)
//}
