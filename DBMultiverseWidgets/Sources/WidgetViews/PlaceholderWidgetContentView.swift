//
//  PlaceholderWidgetContentView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct PlaceholderWidgetContentView: View {
    let isSmallStyle: Bool
    
    var body: some View {
        if isSmallStyle {
            smallPlaceholder
        } else {
            mediumPlaceholder
        }
    }
}


// MARK: - Subviews
private extension PlaceholderWidgetContentView {
    var smallPlaceholder: some View {
        VStack {
            Text("Read")
                .padding(5)
                .withFont(.caption2, textColor: .white)
            Text("Multiverse")
                .textLinearGradient(.yellowText)
            Text("Reader")
                .textLinearGradient(.redText)
        }
        .withFont(autoSizeLineLimit: 1)
    }

    var mediumPlaceholder: some View {
        HStack {
            Image("sampleCoverImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal)
            Spacer()
            VStack {
                Text("Read")
                    .withFont(.caption, textColor: .white, autoSizeLineLimit: 1)

                HStack {
                    Text("Multiverse")
                        .textLinearGradient(.yellowText)
                    Text("Reader")
                        .textLinearGradient(.redText)
                }
                .withFont(autoSizeLineLimit: 1)
            }
        }
    }
}
