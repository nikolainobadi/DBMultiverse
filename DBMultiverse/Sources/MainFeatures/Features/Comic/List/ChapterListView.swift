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
    let chapter: SwiftDataChapter

    var body: some View {
        HStack {
            CustomAsyncImage(url: URL(string: .makeFullURLString(suffix: chapter.coverImageURL)))
            
            VStack(alignment: .leading, spacing: 0) {
                Text("\(chapter.number) - \(chapter.name)")
                    .font(.headline)
                
                Text(chapter.pageRangeText)
                    .font(.subheadline)
                
                if chapter.didFinishReading {
                    Text("Finished")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .asNavLink(chapter)
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}
