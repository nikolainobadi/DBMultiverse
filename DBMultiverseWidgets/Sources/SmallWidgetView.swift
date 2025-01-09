//
//  SmallWidgetView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: ComicImageEntry

    var body: some View {
        VStack {
            HStack {
                Text("Ch")
                    .textLinearGradient(.yellowText)
                Text("1")
                    .textLinearGradient(.redText)
                
                Text(" - 85%")
                    .bold()
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .bold()
            .font(.title2)

            if let image = entry.image {
                image
                    .resizable()
                    .frame(width: 70, height: 90)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Preview
#Preview(as: .systemSmall) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry(date: .now, image: .init("sampleCoverImage"), family: .systemSmall)
}
