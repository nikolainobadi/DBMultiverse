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
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: cacheLastSyncedStateIfNeeded)
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .background {
                    syncWidgetTimelineIfNeeded()
                }
            }
    }
}


// MARK: - Private Methods
private extension WidgetSyncViewModifier {
    func cacheLastSyncedStateIfNeeded() {
        if lastSyncedState == nil {
            lastSyncedState = coverImageManager.loadWidgetSyncState()
        }
    }
    
    func syncWidgetTimelineIfNeeded() {
        guard let currentChapterData = coverImageManager.loadCurrentChapterData() else {
            return
        }
        
        let currentState = WidgetSyncState(chapter: currentChapterData.number, progress: currentChapterData.progress)
        
        if currentState != lastSyncedState {
            lastSyncedState = currentState
            coverImageManager.saveWidgetSyncState(currentState)
            WidgetCenter.shared.reloadTimelines(ofKind: WIDGET_KIND)
        }
    }
}

extension View {
    func syncWidgetData() -> some View {
        modifier(WidgetSyncViewModifier())
    }
}
