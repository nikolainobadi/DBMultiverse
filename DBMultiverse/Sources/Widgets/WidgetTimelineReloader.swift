//
//  WidgetTimelineReloader.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/11/25.
//

import Foundation
import WidgetKit
import DBMultiverseComicKit

@MainActor
final class WidgetTimelineReloader: WidgetTimelineReloading {
    private let coverImageManager: CoverImageManager
    private var cachedState: WidgetSyncState?
    private var debounceTask: Task<Void, Never>?
    private let widgetKind = "DBMultiverseWidgets"
    private let minimumProgressDelta = 5

    init(coverImageManager: CoverImageManager = .init()) {
        self.coverImageManager = coverImageManager
        self.cachedState = coverImageManager.loadWidgetSyncState()
    }
    
    func notifyChapterChange(chapter: Int, progress: Int) {
        debounceTask?.cancel()
        let targetState = WidgetSyncState(chapter: chapter, progress: progress)
        triggerReloadIfNeeded(for: targetState, force: true)
    }
    
    func notifyProgressChange(progress: Int) {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard let self, !Task.isCancelled else { return }
            guard let chapterData = self.coverImageManager.loadCurrentChapterData() else { return }
            let targetState = WidgetSyncState(chapter: chapterData.number, progress: progress)
            self.triggerReloadIfNeeded(for: targetState)
        }
    }
}

// MARK: - Private Helpers
private extension WidgetTimelineReloader {
    func triggerReloadIfNeeded(for targetState: WidgetSyncState, force: Bool = false) {
        let shouldReload: Bool
        
        if force {
            shouldReload = true
        } else if let cachedState {
            if cachedState.chapter != targetState.chapter {
                shouldReload = true
            } else {
                let delta = abs(cachedState.progress - targetState.progress)
                shouldReload = targetState.progress == 100 || delta >= minimumProgressDelta
            }
        } else {
            shouldReload = true
        }
        
        guard shouldReload else { return }
        
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        cachedState = targetState
        coverImageManager.saveWidgetSyncState(targetState)
    }
}
