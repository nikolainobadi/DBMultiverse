//
//  MainFeaturesViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import Foundation

final class MainFeaturesViewModel: ObservableObject {
    private let env: SharedDataENV
    private let loader: ChapterDataStore
    
    init(env: SharedDataENV, loader: ChapterDataStore = ChapterLoaderAdapter()) {
        self.env = env
        self.loader = loader
    }
}


// MARK: - Actions
extension MainFeaturesViewModel {
    func loadData() async throws {
        let (storyChapters, specials) = try await loader.loadChapterLists()
        
        await setStoryChapters(storyChapters)
        await setSpecials(specials)
    }
}


// MARK: - MainActor
@MainActor
private extension MainFeaturesViewModel {
    func setStoryChapters(_ chapters: [Chapter]) {
        env.storyChapters = chapters
    }
    
    func setSpecials(_ specials: [Special]) {
        env.specials = specials
    }
}


// MARK: - Dependencies
protocol ChapterDataStore {
    func loadChapterLists() async throws -> (mainStory: [Chapter], specials: [Special])
}
