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
                HStack {
                    Text("Ch")
                        .textLinearGradient(.yellowText)
                    Text("\(entry.chapter)")
                        .textLinearGradient(.redText)
                }
                .withFont()
                
                Text("\(entry.progress)%")
                    .bold()
                    .withFont(.caption2, textColor: .white, autoSizeLineLimit: 1)
            }
            .bold()
            .padding(.bottom, 5)
            .font(.title2)

            if let image = entry.image {
                image
                    .resizable()
                    .frame(width: 70, height: 90)
            }
        }
        .showingConditionalView(when: entry.chapter == 0) {
            VStack {
                Text("Read")
                    .padding(5)
                    .withFont(.caption2, textColor: .white)
                Text("DB")
                    .textLinearGradient(.yellowText)
                Text("Multiverse")
                    .textLinearGradient(.redText)
            }
            .withFont(autoSizeLineLimit: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Preview
#Preview(as: .systemSmall) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry.makeSample(family: .systemSmall)
}
