//
//  ChapterListFeatureView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct ChapterListFeatureView: View {
    let eventHandler: SwiftDataChapterListEventHandler
    
    private var imageSize: CGSize {
        // TODO: - 
        return isPad ? .init(width: 50, height: 70) : .init(width: 50, height: 70)
    }
    
    var body: some View {
        ChapterListView(imageSize: imageSize, eventHandler: eventHandler) { selection in
            iPhoneComicPicker(selection: selection)
                .showingConditionalView(when: isPad) {
                    iPadComicPicker(selection: selection)
                }
        }
    }
}
