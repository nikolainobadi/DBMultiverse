//
//  MainFeaturesTabView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/30/24.
//

import SwiftUI
import SwiftData
import NnSwiftUIKit

struct MainFeaturesTabView: View {
    @Query(sort: \SwiftDataChapter.number, order: .forward) var chapters: [SwiftDataChapter]
    
    var body: some View {
        TabView {
           ComicFeatureNavStack(chapters: chapters)
                .tabItem {
                    Label("Comic", systemImage: "book")
                }
            
            SettingsFeatureNavStack()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .fetchingChapters(existingChapterNumbers: chapters.map({ $0.number }))
    }
}


// MARK: - Preview
#Preview {
    MainFeaturesTabView()
        .withPreviewModifiers()
}
