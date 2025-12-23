//
//  WidgetSyncViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import SwiftUI
import WidgetKit
import DBMultiverseComicKit

struct WidgetSyncViewModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastSyncedState: WidgetSyncState?
    
    private let coverImageManager = CoverImageManager()
    private let widgetKind = "DBMultiverseWidgets"
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: cacheLastSyncedStateIfNeeded)
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .background else { return }
                syncWidgetTimelineIfNeeded()
            }
    }
}


// MARK: - Private Methods
private extension WidgetSyncViewModifier {
    func cacheLastSyncedStateIfNeeded() {
        guard lastSyncedState == nil else { return }
        lastSyncedState = coverImageManager.loadWidgetSyncState()
    }
    
    func syncWidgetTimelineIfNeeded() {
        guard let currentChapterData = coverImageManager.loadCurrentChapterData() else { return }
        let currentState = WidgetSyncState(chapter: currentChapterData.number, progress: currentChapterData.progress)
        guard currentState != lastSyncedState else { return }
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
        lastSyncedState = currentState
        coverImageManager.saveWidgetSyncState(currentState)
    }
}

extension View {
    func syncWidgetData() -> some View {
        modifier(WidgetSyncViewModifier())
    }
}
