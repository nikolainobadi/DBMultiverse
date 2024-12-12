//
//  ChapterComicView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ChapterComicView: View {
    @Bindable var chapter: SwiftDataChapter
    @StateObject var viewModel: ChapterComicViewModel
    @Environment(\.dismiss) private var dismiss
    
    let updateLastReadPage: (Int) -> Void
    
    var body: some View {
        VStack {
            if let info = viewModel.currentPage, let image = UIImage(data: info.imageData) {
                Text(info.title)
                    .padding(5)
                    .font(.headline)
                
                Text(viewModel.getCurrentPagePosition(chapter: chapter))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                ZoomableImageView(image: image)
            }
            
            ButtonsView(viewModel: viewModel, chapter: chapter) {
                dismiss()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .asyncTask {
            try await viewModel.loadPages(for: chapter)
        }
        .onChange(of: viewModel.currentPageNumber) { _, newValue in
            updateLastReadPage(newValue)

            if chapter.containsPage(newValue) {
                chapter.lastReadPage = newValue
                
                if newValue == chapter.endPage {
                    chapter.didFinishReading = true
                }
            }
        }
    }
}


// MARK: - ButtonsView
fileprivate struct ButtonsView: View {
    @ObservedObject var viewModel: ChapterComicViewModel
    
    let chapter: SwiftDataChapter
    let finished: () -> Void
    
    private var isLastPage: Bool {
        return viewModel.currentPageNumber == chapter.endPage
    }
    
    var body: some View {
        HStack {
            HapticButton("Previous") {
                viewModel.previousPage(start: chapter.startPage)
            }
            .tint(.red)
            .disabled(viewModel.currentPageNumber <= chapter.startPage)
            
            Spacer()
            
            HapticButton(isLastPage ? "Finish Chapter" : "Next") {
                if isLastPage {
                    finished()
                } else {
                    viewModel.nextPage(end: chapter.endPage)
                }
            }
            .disabled(viewModel.currentPageNumber >= chapter.endPage)
        }
        .padding()
    }
}


// MARK: - Preview
#Preview {
    class PreviewLoader: ChapterComicLoader {
        func loadPages(chapter: SwiftDataChapter) async throws -> [PageInfo] { return [] }
    }
    
    return NavStack(title: "Chapter 1") {
        ChapterComicView(chapter: PreviewSampleData.sampleChapter, viewModel: .init(currentPageNumber: 0, loader: PreviewLoader()), updateLastReadPage: { _ in })
            .withPreviewModifiers()
    }
}
