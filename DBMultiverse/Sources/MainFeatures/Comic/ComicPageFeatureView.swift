//
//  ComicPageFeatureView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct ComicPageFeatureView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ComicPageViewModel
    
    var body: some View {
        Text("Loading page...")
            .withFont()
            .showingViewWithOptional(viewModel.currentPage) { page in
                ComicPageContentView(
                    page: page,
                    nextPage: viewModel.nextPage,
                    previousPage: viewModel.previousPage,
                    finishChapter: { dismiss() } 
                )
            }
            .throwingTask {
                try await viewModel.loadData()
            }
            
    }
}

// MARK: - Content
fileprivate struct ComicPageContentView: View {
    let page: ComicPage
    let nextPage: () -> Void
    let previousPage: () -> Void
    let finishChapter: () -> Void
    
    var body: some View {
        iPhoneComicPageView(page: page, nextPage: nextPage, previousPage: previousPage, finishChapter: finishChapter)
            .showingConditionalView(when: isPad) {
                iPadComicPageView(page: page, nextPage: nextPage, previousPage: previousPage, finishChapter: finishChapter)
            }
    }
}
