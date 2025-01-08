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
    let eventHandler: ChapterListEventHandler
    let comicPicker: (Binding<ComicType>) -> ComicPicker
    
    private var sections: [ChapterSection] {
        // TODO: - need to account for current chapter
        return eventHandler.makeSections(type: selection)
    }
    
    public init(imageSize: CGSize, eventHandler: ChapterListEventHandler, @ViewBuilder comicPicker: @escaping (Binding<ComicType>) -> ComicPicker) {
        self.imageSize = imageSize
        self.eventHandler = eventHandler
        self.comicPicker = comicPicker
    }
    
    public var body: some View {
        VStack {
            comicPicker($selection)
            
            List(sections, id: \.title) { section in
                DynamicSection(section.title) {
                    ForEach(section.chapters, id: \.name) { chapter in
                        ChapterRow(chapter, url: eventHandler.makeImageURL(for: chapter), imageSize: imageSize)
                            .asNavLink(chapter)
                            .withUnreadSwipeAction(isActive: true) {
                                eventHandler.unreadChapter(chapter)
                            }
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


// MARK: - Row
fileprivate struct ChapterRow: View {
    let url: URL?
    let chapter: Chapter
    let imageSize: CGSize?
    
    init(_ chapter: Chapter, url: URL?, imageSize: CGSize?) {
        self.url = url
        self.chapter = chapter
        self.imageSize = imageSize
    }
    
    var body: some View {
        HStack {
            CustomAsyncImage(url: url, size: imageSize)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(chapter.rowTitle)
                    .withFont(.headline, autoSizeLineLimit: 1)
                
                Text(chapter.pageRangeText)
                    .withFont(textColor: .secondary)
                
                if chapter.didFinishReading {
                    Text("Finished")
                        .padding(.horizontal)
                        .withFont(.caption, textColor: .red)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// MARK: - Dependencies
public protocol ChapterListEventHandler {
    func unreadChapter(_ chapter: Chapter)
    func makeImageURL(for chapter: Chapter) -> URL?
    func makeSections(type: ComicType) -> [ChapterSection]
}


// MARK: - Extension Dependencies
extension View {
    func withUnreadSwipeAction(isActive: Bool, action: @escaping () -> Void) -> some View {
        withSwipeAction(info: .init(prompt: "Unread"), systemImage: "eraser.fill", tint: .gray, edge: .leading, isActive: isActive, action: action)
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
