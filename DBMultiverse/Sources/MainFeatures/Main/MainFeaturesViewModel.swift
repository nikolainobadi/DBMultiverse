//
//  MainFeaturesViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

final class MainFeaturesViewModel: ObservableObject {
    @AppStorage(.lastReadSpecialPage) var lastReadSpecialPage: Int = 168
    @AppStorage(.lastReadMainStoryPage) var lastReadMainStoryPage: Int = 0
}


// MARK: - Actions
extension MainFeaturesViewModel {
    func updateCurrentPageNumber(_ pageNumber: Int, comicType: ComicType) {
        Task { @MainActor [unowned self] in
            switch comicType {
            case .story:
                print("updated last read story page")
                lastReadMainStoryPage = pageNumber
            case .specials:
                print("updating last read special page")
                lastReadSpecialPage = pageNumber
            }
        }
    }
    
    func getCurrentPageNumber(for type: ComicType) -> Int {
        switch type {
        case .story:
            return lastReadMainStoryPage
        case .specials:
            return lastReadSpecialPage
        }
    }
}
