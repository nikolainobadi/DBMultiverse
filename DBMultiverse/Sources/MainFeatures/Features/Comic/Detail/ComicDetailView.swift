//
//  ComicDetailView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ComicDetailView: View {
    @Bindable var chapter: SwiftDataChapter
    @StateObject var viewModel: ComicDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    let updateLastReadPage: (Int) -> Void
    
    var body: some View {
        iPhoneComicView(chapter: chapter, viewModel: viewModel, dismiss: { dismiss() })
            .showingConditionalView(when: isPad) {
                iPadComicView(chapter: chapter, viewModel: viewModel, dismiss: { dismiss() })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .asyncTask {
                try await viewModel.loadInitialPages(for: chapter.info)
            }
            .onChange(of: viewModel.didFetchPages) {
                viewModel.loadRemainingPages(for: chapter.info)
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


// MARK: - ImageContentView
struct ComicImageContentView: View {
    @Bindable var chapter: SwiftDataChapter
    @ObservedObject var viewModel: ComicDetailViewModel
    
    var body: some View {
        VStack {
            Text("Loading page...")
                .showingViewWithOptional(viewModel.currentPageInfo?.image) { image in
                    Text(chapter.name)
                    Text(viewModel.getCurrentPagePosition(chapterInfo: chapter.info))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ZoomableImageView(image: image)
                        .padding()
                }
        }
    }
}


// MARK: - iPhone
fileprivate struct iPhoneComicView: View {
    @Bindable var chapter: SwiftDataChapter
    @ObservedObject var viewModel: ComicDetailViewModel
    
    let dismiss: () -> Void
    
    private var isLastPage: Bool {
        return viewModel.currentPageNumber == chapter.endPage
    }
    
    var body: some View {
        VStack {
            ComicImageContentView(chapter: chapter, viewModel: viewModel)
            
            HStack {
                HapticButton("Previous") {
                    viewModel.previousPage(start: chapter.startPage)
                }
                .tint(.red)
                .disabled(viewModel.currentPageNumber <= chapter.startPage)
                
                Spacer()
                
                HapticButton(isLastPage ? "Finish Chapter" : "Next") {
                    if isLastPage {
                        dismiss()
                    } else {
                        viewModel.nextPage(end: chapter.endPage)
                    }
                }
                .disabled(viewModel.currentPageNumber >= chapter.endPage)
            }
            .padding()
        }
    }
}


// MARK: - iPad
fileprivate struct iPadComicView: View {
    @Bindable var chapter: SwiftDataChapter
    @ObservedObject var viewModel: ComicDetailViewModel
    
    let dismiss: () -> Void
    
    private var isLastPage: Bool {
        return viewModel.currentPageNumber == chapter.endPage
    }
    
    var body: some View {
        HStack {
            Button {
                viewModel.previousPage(start: chapter.startPage)
            } label: {
                Image(systemName: "chevron.left")
            }
            .tint(.red)
            .opacity(viewModel.currentPageNumber <= chapter.startPage ? 0 : 1)
            .buttonStyle(.customButtonStyle(textColor: .red))
            
            Spacer()
            ComicImageContentView(chapter: chapter, viewModel: viewModel)
            Spacer()
            
            Button {
                if isLastPage {
                    dismiss()
                } else {
                    viewModel.nextPage(end: chapter.endPage)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .showingConditionalView(when: isLastPage) {
                        VStack {
                            Text("Finish")
                            Text("Chapter")
                        }
                    }
            }
            .opacity(viewModel.currentPageNumber >= chapter.endPage ? 0 : 1)
            .buttonStyle(.customButtonStyle(textColor: .blue))
        }
        .padding(5)
    }
}


// MARK: - Preview
#Preview {
    class PreviewLoader: ChapterComicLoader {
        func loadPages(chapter: SwiftDataChapter) async throws -> [PageInfo] {  [] }
        func loadPages(chapterNumber: Int, pages: [Int]) async throws -> [PageInfo] { []}
        func loadPages(chapterNumber: Int, start: Int, end: Int) async throws -> [PageInfo] { [] }
    }
    
    return NavStack(title: "Chapter 1") {
        ComicDetailView(chapter: PreviewSampleData.sampleChapter, viewModel: .init(currentPageNumber: 0, loader: PreviewLoader()), updateLastReadPage: { _ in })
            .withPreviewModifiers()
    }
}


// MARK: - Extension Dependencies
fileprivate extension PageInfo {
    var image: UIImage? {
        return .init(data: imageData)
    }
}

extension SwiftDataChapter {
    var info: ChapterInfo {
        return .init(number: number, startPage: startPage, endPage: endPage, lastReadPage: lastReadPage)
    }
}
