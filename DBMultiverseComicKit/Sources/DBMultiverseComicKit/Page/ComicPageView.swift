//
//  ComicPageView.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

public struct ComicPageView<DetailView: View>: View {
    @StateObject var viewModel: ComicPageViewModel
    
    let detailView: (ComicPageViewModel) -> DetailView
    
    public init(loader: ComicPageLoader, @ViewBuilder detailView: @escaping (ComicPageViewModel) -> DetailView) {
        // TODO: - 
        self._viewModel = .init(wrappedValue: .init(currentPageNumber: 0, loader: loader))
        self.detailView = detailView
    }
    
//    let detailView: (ComicPage) -> DetailView
//    
//    public init(loader: ComicPageLoader, @ViewBuilder detailView: @escaping (ComicPage) -> DetailView) {
//        self._viewModel = .init(wrappedValue: .init(loader: loader))
//        self.detailView = detailView
//    }
    
    public var body: some View {
        Text("Loading page...")
            .withFont()
            .showingConditionalView(when: viewModel.currentPage != nil) {
                detailView(viewModel)
            }
//            .showingViewWithOptional(viewModel.currentPage) { page in
//                detailView(page)
//            }
            .asyncTask {
                try await viewModel.loadData()
            }
            .onChange(of: viewModel.didFetchInitialPages) {
                viewModel.loadRemainingPages()
            }
        // TODO: - need to update last read chapter
    }
}


// MARK: - Preview
#Preview {
    class PreviewLoader: ComicPageLoader {
        func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [ComicPage] {
            return []
        }
    }
    
    return ComicPageView(loader: PreviewLoader()) { _ in
        Text("detail view")
    }
}
