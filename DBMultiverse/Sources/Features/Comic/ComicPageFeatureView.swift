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
                pageContent(page) {
                    dismiss()
                }
            }
            .throwingTask {
                try await viewModel.loadData()
            }
            
    }
}

// MARK: - Content
private extension ComicPageFeatureView {
    @ViewBuilder
    func pageContent(_ page: ComicPage, finishChapter: @escaping () -> Void) -> some View {
        iPhoneComicPageView(page: page, nextPage: viewModel.nextPage, previousPage: viewModel.previousPage, finishChapter: finishChapter)
            .showingConditionalView(when: isPad) {
                iPadComicPageView(page: page, nextPage: viewModel.nextPage, previousPage: viewModel.previousPage, finishChapter: finishChapter)
            }
    }
}
