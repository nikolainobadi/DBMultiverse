//
//  DBMultiverseWidgetContentView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/22/25.
//

import SwiftUI

struct DBMultiverseWidgetContentView: View {
    let entry: ComicImageEntry
    
    var body: some View {
        if entry.family == .systemSmall {
            SmallWidgetView(entry: entry)
        } else {
            MediumWidgetView(entry: entry)
        }
    }
}
