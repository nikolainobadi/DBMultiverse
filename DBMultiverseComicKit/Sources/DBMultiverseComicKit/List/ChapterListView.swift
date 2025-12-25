//
//  ChapterListView.swift
//  
//
//  Created by Nikolai Nobadi on 1/7/25.
//

import SwiftUI
import NnSwiftUIKit

public struct ChapterListView<ComicPicker: View>: View {
    @State private var selection: ComicType = .story
    
    let imageSize: CGSize
    let eventHandler: any ChapterListEventHandler
    let comicPicker: (Binding<ComicType>) -> ComicPicker
    
    public init(imageSize: CGSize, eventHandler: any ChapterListEventHandler, @ViewBuilder comicPicker: @escaping (Binding<ComicType>) -> ComicPicker) {
        self.imageSize = imageSize
        self.eventHandler = eventHandler
        self.comicPicker = comicPicker
    }
    
    public var body: some View {
        VStack {
            comicPicker($selection)
            
            List(eventHandler.makeSections(type: selection), id: \.title) { section in
                DynamicSection(section.title, gradient: section.gradient) {
                    ForEach(section.chapters, id: \.name) { chapter in
                        chapterRow(chapter)
                            .asNavLink(ChapterRoute(chapter: chapter, comicType: selection))
                            .withToggleReadSwipeAction(isRead: chapter.didFinishReading) {
                                eventHandler.toggleReadStatus(for: chapter)
                            }
                    }
                    
                    if let chapter = section.chapters.first {
                        Button {
                            eventHandler.startNextChapter(currentChapter: chapter)
                        } label: {
                            Text("Start Reading Next Chapter")
                                .withFont()
                                .underline()
                                .frame(maxWidth: .infinity)
                                .textLinearGradient(.yellowText)
                        }
                        .onlyShow(when: section.canShowNextChapterButton && selection == .story)
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Row
private extension ChapterListView {
    func chapterRow(_ chapter: Chapter) -> some View {
        HStack {
            CustomAsyncImage(url: eventHandler.makeImageURL(for: chapter), size: imageSize)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(chapter.rowTitle)
                    .withFont(.headline, autoSizeLineLimit: 1)
                
                Text(chapter.pageRangeText)
                    .withFont(textColor: .secondary)
                
                if let lastReadPage = chapter.lastReadPage {
                    Text("Last read page: \(lastReadPage)")
                        .withFont(.caption2, textColor: .secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottomTrailing) {
            if chapter.didFinishReading {
                Text("Finished")
                    .padding()
                    .withFont(.caption)
                    .textLinearGradient(.redText)
            }
        }
    }
}


// MARK: - Dependencies
@MainActor
public protocol ChapterListEventHandler {
    func toggleReadStatus(for chapter: Chapter)
    func startNextChapter(currentChapter: Chapter)
    func makeImageURL(for chapter: Chapter) -> URL?
    func makeSections(type: ComicType) -> [ChapterSection]
}


// MARK: - Extension Dependencies
extension View {
    func withToggleReadSwipeAction(isRead: Bool, action: @escaping () -> Void) -> some View {
        withSwipeAction(info: .init(prompt: isRead ? "Unread" : "Complete"), systemImage: isRead ? "eraser.fill" : "book", tint: isRead ? .gray : .blue, edge: .leading, action: action)
    }
}

extension Chapter {
    var rowTitle: String {
        return "\(number) - \(name)"
    }
    
    var pageRangeText: String {
        return "Pages: \(startPage) - \(endPage)"
    }
}

extension ChapterSection {
    var canShowNextChapterButton: Bool {
        guard type == .currentChapter, let chapter = chapters.first else {
            return false
        }
        
        return chapter.didFinishReading
    }
    
    var gradient: LinearGradient? {
        switch type {
        case .currentChapter:
            return .lightStarrySky
        default:
            return nil
        }
    }
}
