//
//  ChapterListViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/11/24.
//

import Foundation

final class ChapterListViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    
    private let defaults: UserDefaults
    
    init(store: SharedDataENV, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        let completedChapterList = (defaults.value(forKey: .completedChapterListKey) as? [String]) ?? []
        
//        store.$storyChapters
//            .map { list in
//                return list.map { chapter in
//                    guard completedChapterList.contains(chapter.number) else {
//                        return chapter
//                    }
//                    var updated = chapter
//                    updated.didRead = true
//                    return updated
//                }
//            }
//            .assign(to: &$chapters)
    }
}


// MARK: - Actions
extension ChapterListViewModel {
    func unreadChapter(_ chapter: Chapter) {
//        var completedChapterList = (defaults.value(forKey: .completedChapterListKey) as? [String]) ?? []
//        
//        if let index = completedChapterList.firstIndex(where: { $0 == chapter.number }) {
//            completedChapterList.remove(at: index)
//            
//            defaults.setValue(completedChapterList, forKey: .completedChapterListKey)
//        }
//        
//        if let index = chapters.firstIndex(where: { $0.number == chapter.number }) {
//            chapters[index].didRead = false
//        }
    }
}
