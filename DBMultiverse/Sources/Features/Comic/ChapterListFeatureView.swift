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
        return .init(width: getWidthPercent(15), height: getHeightPercent(isPad ? 15 : 10))
    }
    
    var body: some View {
        ChapterListView(imageSize: imageSize, eventHandler: eventHandler) { selection in
            if isPad {
                iPadComicPicker(selection: selection)
            } else {
                iPhoneComicPicker(selection: selection)
            }
        }
    }
}
