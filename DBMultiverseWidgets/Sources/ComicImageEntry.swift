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
    let image: Image?
    let family: WidgetFamily
}
