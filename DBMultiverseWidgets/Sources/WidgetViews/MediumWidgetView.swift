//
//  MediumWidgetView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct MediumWidgetView: View {
    let entry: ComicImageEntry
    
    var body: some View {
        HStack {
            if let image = entry.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Spacer()
            
            HStack {
                VStack {
                    ChapterHeaderView(chapter: entry.chapter)
                        .padding(.bottom, 5)

                    Text(entry.name)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .withFont(.caption, textColor: .white,  autoSizeLineLimit: 2)
                }

                Text("\(entry.progress)%")
                    .withFont(textColor: .white)
            }
        }
        .showingConditionalView(when: entry.chapter == 0) {
            PlaceholderWidgetContentView(isSmallStyle: false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


#if DEBUG
// MARK: - Preview
#Preview(as: .systemMedium) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry.makeSample(family: .systemMedium)
}
#endif
