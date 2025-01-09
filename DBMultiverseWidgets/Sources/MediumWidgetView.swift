//
//  MediumWidgetView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    var body: some View {
        VStack {
            
        }
    }
}


// MARK: - Preview
#Preview(as: .systemMedium) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry(date: .now, image: .init("sampleCoverImage"), family: .systemMedium)
}
