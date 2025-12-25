//
//  iPhoneComicPageView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import NnSwiftUIKit
import DBMultiverseComicKit

struct iPhoneComicPageView: View {
    let page: ComicPage
    let nextPage: () -> Void
    let previousPage: () -> Void
    let finishChapter: () -> Void
    
    var body: some View {
        VStack {
            ComicPageImageView(page: page)
            
            HStack {
                HapticButton("Previous", action: previousPage)
                .tint(.red)
                .disabled(page.isFirstPage)
                
                Spacer()
                
                if page.isLastPage {
                    HapticButton("Finish Chapter", action: finishChapter)
                        .tint(.red)
                } else {
                    HapticButton("Next", action: nextPage)
                        .tint(.blue)
                }
            }
            .padding()
        }
    }
}
