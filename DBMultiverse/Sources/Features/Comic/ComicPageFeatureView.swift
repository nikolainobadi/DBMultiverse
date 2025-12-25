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
    @StateObject private var viewModel: ComicPageViewModel
    
    init(viewModel: @autoclosure @escaping () -> ComicPageViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
    }
    
    var body: some View {
        if let currentPage = viewModel.currentPage {
            pageContent(currentPage) {
                dismiss()
            }
        } else {
            Text("Loading page...")
                .withFont()
                .throwingTask {
                    try await viewModel.loadData()
                }
        }
    }
}

// MARK: - Content
private extension ComicPageFeatureView {
    @ViewBuilder
    func pageContent(_ page: ComicPage, finishChapter: @escaping () -> Void) -> some View {
        if isPad {
            iPadComicPageView(page: page, nextPage: viewModel.nextPage, previousPage: viewModel.previousPage, finishChapter: finishChapter)
        } else {
            iPhoneComicPageView(page: page, nextPage: viewModel.nextPage, previousPage: viewModel.previousPage, finishChapter: finishChapter)
        }
    }
}
