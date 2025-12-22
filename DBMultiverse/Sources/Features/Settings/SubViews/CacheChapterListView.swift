//
//  CacheChapterListView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI

struct CacheChapterListView: View {
    let chapters: [CachedChapter]
    
    var body: some View {
        List(chapters, id: \.number) { chapter in
            HStack {
                Text("Chapter \(chapter.number)")
                Spacer()
                Text("\(chapter.imageCount) Images")
                    .foregroundColor(.secondary)
            }
        }
    }
}


#if DEBUG
// MARK: - Preview
#Preview {
    CacheChapterListView(chapters: CachedChapter.sampleList)
}
#endif
