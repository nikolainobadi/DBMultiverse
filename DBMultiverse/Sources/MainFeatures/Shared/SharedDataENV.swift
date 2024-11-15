//
//  SharedDataENV.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/14/24.
//

import Foundation

final class SharedDataENV: ObservableObject {
    @Published var selectedChapter: Chapter?
    @Published var completedChapterList: [String]
    
    init() {
        completedChapterList = UserDefaults.standard.array(forKey: .completedChapterListKey) as? [String] ?? []
    }
}


// MARK: - Actions
extension SharedDataENV {
    func finishChapter(number: String) {
        if !completedChapterList.contains(number) {
            completedChapterList.append(number)
            UserDefaults.standard.setValue(completedChapterList, forKey: .completedChapterListKey)
        }
        
        selectedChapter = nil
    }
}
