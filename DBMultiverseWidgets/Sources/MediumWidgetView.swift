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
                    HStack {
                        HStack {
                            Text("Ch")
                                .textLinearGradient(.yellowText)
                            Text("\(entry.chapter)")
                                .textLinearGradient(.redText)
                        }
                        .withFont()
                    }
                    .bold()
                    .padding(.bottom, 5)
                    .font(.title2)
                    
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
                        Text("DB")
                            .textLinearGradient(.yellowText)
                        Text("Multiverse")
                            .textLinearGradient(.redText)
                    }
                    .withFont(autoSizeLineLimit: 1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Preview
#Preview(as: .systemMedium) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry.makeSample(family: .systemMedium)
}
