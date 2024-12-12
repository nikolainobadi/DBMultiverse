//
//  ChapterComicView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/11/24.
//

import SwiftUI
import NnSwiftUIKit

struct ChapterComicView: View {
    @Binding var lastReadPage: Int
    @Bindable var chapter: SwiftDataChapter
    @StateObject var viewModel: ChapterComicViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var isLastPage: Bool {
        return viewModel.currentPageNumber == chapter.endPage
    }
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .asyncTask {
            try await viewModel.loadPages(for: chapter)
        }
        .onChange(of: viewModel.currentPageNumber) { _, newValue in
            if chapter.containsPage(newValue) {
                chapter.lastReadPage = newValue
                
                if newValue == chapter.endPage {
                    chapter.didFinishReading = true
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    NavStack(title: "Chapter 1") {
        ChapterComicView(lastReadPage: .constant(0), chapter: PreviewSampleData.sampleChapter, viewModel: .init(currentPageNumber: 0, loader: PreviewChapterComicLoader()))
            .withPreviewModifiers()
    }
}


class PreviewChapterComicLoader: ChapterComicLoader {
    func loadPages(start: Int, end: Int) async throws -> [PageInfo] {
        return []
    }
}


// MARK: - HapticButton
struct HapticButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }
        .buttonStyle(.bordered)
    }
}


struct ZoomableImageView: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let image: UIImage

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = CGSize(
                                width: lastOffset.width + gesture.translation.width,
                                height: lastOffset.height + gesture.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let newScale = lastScale * value
                            scale = min(max(newScale, 1.0), 5.0) // Limit zoom between 1x and 5x
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                scale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

final class ChapterComicViewModel: ObservableObject {
    @Published var pages: [PageInfo] = []
    @Published var currentPageNumber: Int
    
    private let loader: ChapterComicLoader
    
    init(currentPageNumber: Int, loader: ChapterComicLoader) {
        self.currentPageNumber = currentPageNumber
        self.loader = loader
    }
}


// MARK: - DisplayData
extension ChapterComicViewModel {
    var currentPage: PageInfo? {
        return pages.first(where: { $0.pageNumber == currentPageNumber })
    }
}


// MARK: - Actions
extension ChapterComicViewModel {
    func getCurrentPagePosition(chapter: SwiftDataChapter) -> String {
        let totalPages = chapter.endPage - chapter.startPage
        let currentPageIndex = currentPageNumber - chapter.startPage
        
        return "\(currentPageIndex)/\(totalPages)"
    }
    
    func loadPages(for chapter: SwiftDataChapter) async throws {
        let pages = try await loader.loadPages(start: chapter.startPage, end: chapter.endPage)
        
        await setPages(pages, firstPage: chapter.startPage)
    }
    
    func previousPage(start: Int) {
        if currentPageNumber > start {
            currentPageNumber -= 1
        }
    }
    
    func nextPage(end: Int) {
        if currentPageNumber < end {
            currentPageNumber += 1
        }
    }
}


// MARK: MainActor
@MainActor
private extension ChapterComicViewModel {
    func setPages(_ pages: [PageInfo], firstPage: Int) {
        self.pages = pages
        
        if !pages.compactMap({ Int($0.pageNumber) }).contains(currentPageNumber) {
            currentPageNumber = firstPage
        }
    }
}


// MARK: - Dependencies
protocol ChapterComicLoader {
    func loadPages(start: Int, end: Int) async throws -> [PageInfo]
}

import SwiftSoup

final class ChapterComicLoaderAdapter: ChapterComicLoader {
    func loadPages(start: Int, end: Int) async throws -> [PageInfo] {
        var pages: [PageInfo] = []
        
        for page in start...end {
            if let pageInfo = try await fetchImage(page: page) {
                pages.append(pageInfo)
            }
        }
        
        return pages
    }
}

private extension ChapterComicLoaderAdapter {
    func fetchImage(page: Int) async throws -> PageInfo? {
        guard let url = URL(string: "\("https://www.dragonball-multiverse.com/en/page-")\(page).html") else {
            return nil
        }
        
        let data = try await URLSession.shared.data(from: url).0
        let imageURLInfo = try parseHTMLForImageURL(data: data)
        
        return try await downloadImage(from: imageURLInfo)
    }
    
    func parseHTMLForImageURL(data: Data) throws -> PageImageURLInfo? {
        let html = String(data: data, encoding: .utf8) ?? ""
        let document = try SwiftSoup.parse(html)
        
        var chapter: Int?
        var page: Int?
        
        guard let metaTag = try document.select("meta[property=og:title]").first() else {
            return nil
        }
        
        let content = try metaTag.attr("content")
        let chapterRegex = try NSRegularExpression(pattern: #"Chapter (\d+)"#)
        let pageRegex = try NSRegularExpression(pattern: #"Page (\d+)"#)
        let chapterMatch = chapterRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        let pageMatch = pageRegex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content))
        chapter = {
            if let match = chapterMatch, let range = Range(match.range(at: 1), in: content) {
                return Int(content[range])
            }
            return nil
        }()
        
        page = {
            if let match = pageMatch, let range = Range(match.range(at: 1), in: content) {
                return Int(content[range])
            }
            return nil
        }()
        
        guard let imgElement = try document.select("img[id=balloonsimg]").first() else {
            return nil
        }
        
        let imgSrc = try imgElement.attr("src")
        let url = URL(string: "https://www.dragonball-multiverse.com" + imgSrc)
        
        guard let chapter, let page else {
            return nil
        }
        
        return .init(url: url, chapter: chapter, pageNumber: page)
    }
    
    func downloadImage(from info: PageImageURLInfo?) async throws -> PageInfo? {
        guard let info, let url = info.url else {
            return nil
        }
        
        let data = try await URLSession.shared.data(from: url).0
        
        return .init(chapter: info.chapter, pageNumber: info.pageNumber, imageData: data)
    }
}

struct PageInfo {
    let chapter: Int
    let pageNumber: Int
    let imageData: Data
    
    var title: String {
        if pageNumber == 0 {
            return ""
        }
        
        return "Chapter \(chapter) page \(pageNumber)"
    }
}

struct PageImageURLInfo {
    let url: URL?
    let chapter: Int
    let pageNumber: Int
}

extension SwiftDataChapter {
    func containsPage(_ page: Int) -> Bool {
        return page >= startPage && page <= endPage
    }
}
