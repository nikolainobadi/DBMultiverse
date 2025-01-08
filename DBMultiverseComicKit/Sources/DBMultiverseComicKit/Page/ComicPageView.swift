//
//  ComicPageView.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

struct ComicPageView<DetailView: View>: View {
    @StateObject var viewModel: ComicPageViewModel
    
    let detailView: (ComicPage) -> DetailView
    
    var body: some View {
        Text("Loading page...")
            .withFont()
            .showingViewWithOptional(viewModel.currentPage) { page in
                detailView(page)
            }
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
    
    return ComicPageView(viewModel: .init(loader: PreviewLoader())) { _ in
        Text("image view")
    }
}


// MARK: - Extension Dependencies
fileprivate extension ComicPage {
    var isFirstPage: Bool {
        return pagePosition.page == 0
    }
    
    var isLastPage: Bool {
        return pagePosition.page == pagePosition.totalPages
    }
}
