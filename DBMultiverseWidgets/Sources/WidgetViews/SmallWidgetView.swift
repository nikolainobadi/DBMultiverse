//
//  SmallWidgetView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct SmallWidgetView: View {
    let entry: ComicImageEntry

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ChapterHeaderView(chapter: entry.chapter)

                Text("\(entry.progress)%")
                    .bold()
                    .withFont(.caption2, textColor: .white, autoSizeLineLimit: 1)
            }
            .padding(.bottom, 5)

            if let image = entry.image {
                image
                    .resizable()
                    .frame(width: 70, height: 90)
            }
        }
        .showingConditionalView(when: entry.chapter == 0) {
            PlaceholderWidgetContentView(isSmallStyle: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
