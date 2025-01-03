//
//  ChapterListView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftUI
import NnSwiftUIKit

struct ChapterListView: View {
    let lastReadPage: Int
    let sections: [ChapterSection]
    let currentChapter: SwiftDataChapter?
    
    var body: some View {
        List {
            if let currentChapter {
                Section("Current Chapter") {
                    ChapterRow(chapter: currentChapter)
                }
            }
            
            ForEach(sections, id: \.title) { section in
                Section(section.title) {
                    ForEach(section.chapters) { chapter in
                        ChapterRow(chapter: chapter)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}


// MARK: - Row
fileprivate struct ChapterRow: View {
    @Bindable var chapter: SwiftDataChapter
    
    private var url: URL? {
        return URL(string: .makeFullURLString(suffix: chapter.coverImageURL))
    }
    
    var body: some View {
        HStack {
            CustomAsyncImage(
                url: url,
                width: getWidthPercent(15),
                height: getHeightPercent(isPad ? 15 : 10)
            )
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(chapter.number) - \(chapter.name)")
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
        .asNavLink(chapter)
        .withSwipeAction(
            info: .init(prompt: "Unread"),
            systemImage: "eraser.fill",
            tint: .gray,
            edge: .leading,
            isActive: chapter.didFinishReading,
            action: chapter.markAsUnread
        )
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}


// MARK: - Extension Dependencies
fileprivate extension SwiftDataChapter {
    func markAsUnread() {
        didFinishReading = false
        lastReadPage = startPage
    }
}
